import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as path from 'path'
import { DBPrefix,  Message, Reply, User } from './models';
import * as delivery from './proc/delivery';
import * as convert from './proc/convert';


admin.initializeApp();

const db = admin.firestore();


/// メッセージ投稿トリガー (Firestore)
export const posted = functions.firestore
    .document(DBPrefix.posted + '/{messageId}').onCreate( async (snapshot, _) => {
        
        // Get an object representing document
        const msg = snapshot.data() as Message;

        // 画像登録が存在する場合は画像の登録 - 変換後に処理が必要となるため,
        // ここでは特に処理を行わない
        if (msg.imgReg) return;

        // 上記意外の場合はメッセージ配信処理
        return delivery.deliveryMessage(msg, db)
            .then(() => {
                console.log('success set documents!!');
            })
            .catch(err => {
                console.log('failed set documents...orz');
                console.log(err);
            });

});

/// リプライトリガー
export const noticeByReply = functions.firestore
    .document(DBPrefix.conversation + '/{convId}/' + DBPrefix.replys + '/{repId}').onCreate( async (snapshot, context) => {
        
        const convId = context.params.convId;
        const reply = snapshot.data() as Reply;

        console.log(`conversation onCreate replys...${convId}`);
        console.log(`send by ${reply.from.id}`);

        // 送信先のユーザ情報を取得
        const recv = (await db.collection(DBPrefix.users).doc(reply.to).get()).data() as User;
        // トークンが存在しな場合は通知が許可されていないため処理なし
        if (recv.token === null) {
            console.log('receiver is not register device token');
            return;
        }

        // 通知をOFFに設定している場合も通知を送らない
        if (!recv.notification) {
            console.log(`receiver's notification is off. [${recv.id}]`);
            return;
        }

        const payload = {
            notification: {
                title: `${reply.from.name}さんからメッセージが届きました.`,
                body: reply.message
            },
            data: {
                id: convId,
                message: convId,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };

        // 通知送信
        const response = await admin.messaging().sendToDevice(recv.token, payload);
        response.results.forEach((result, index) => {
            const error = result.error;
            if (error) {
              console.error('Failure sending notification to', recv.token, error);
            }
        });
        
        return;
});

/// アクティブユーザ数更新用のスケジュールトリガー
export const activity = functions.pubsub.schedule('every 30 minutes').onRun(async (context) => {

    console.log('start active users count update');

    // アクティブなユーザ数を更新
    // アプリ上でも更新しているが、異常終了した場合に不正確な値になるため、
    // ここでユーザ数から正確に取得
    const users = (await db.collection(DBPrefix.users).where('active', '==', true).get());
    const count = users.docs.length;

    // アクティブなユーザ数を取得したら更新
    await db.collection(DBPrefix.activate).doc(DBPrefix.activeId).update(
        { users: count }
    );

    console.log('success active users count update!');
    return;
});

/// 拒否リストに登録
export const refusal = functions.https.onCall( async (data, _)=> {

    const uid = data.uid;
    const messageId = data.messageId;

    console.log(`refusal report...[${uid}], [${messageId}]`);

    // メッセージを取得
    const msg = (await db.collection(DBPrefix.posted).doc(messageId).get()).data() as Message;

    // レポートに登録
    await db.collection(DBPrefix.reports).doc().set(
        {
            uid: uid,
            messageId: messageId,
            message: {
                message: msg.message,
                img: msg.img,
                timestamp: msg.timestamp
            }
        }
    );

    // 一定の件数のレポートが来た場合、アカウントを無効化する(過去も含めて)
    const datas = (await db.collection(DBPrefix.users).where('uid', '==', uid).get()).docs;
    if (datas.length <= 20) return;
    
    const date = new Date();
    
    // アカウントを無効化
    await db.collection(DBPrefix.users).doc(uid).update(
        { 
            available: false,
            timestamp: date.getTime()
        }
    );
});

/// アクティブユーザ数更新用のスケジュールトリガー
export const expiredPosts = functions.pubsub.schedule('every 1 hours').onRun(async (context) => {

    console.log('start delete expired posts');

    // 現在時刻から1時間前の時間を算出し、そこを期限とする
    const date = new Date();
    const hours = 1000 * 60 * 60;
    const expired = date.getTime() - hours;

    // 期限より過去の投稿メッセージが全て削除
    const dates = (await db.collection(DBPrefix.posted).where('timestamp', '<=', expired).get()).docs;
    if (dates.length === 0) {
        console.log(`success delete expired posts [0]`);
        return;
    }

    // 取得した投稿分、削除処理を行う
    // 削除は投稿、振り分け分、画像の全てにおいて削除を行うが、会話分については削除しない
    for (const i in dates) {
        const msg = dates[i].data() as Message;
        // 画像付きの投稿の場合、画像を削除
        if (msg.img !== null) {
            const bucket = admin.storage().bucket();
            const filePath = 'messages';
            const imgPath = path.join(filePath, msg.file);
            await bucket.file(imgPath).delete();
        }

        // 投稿メッセージを削除
        await db.collection(DBPrefix.posted).doc(msg.id).delete();

        // 振り分けられたkメッセージを削除
        const receivers = (await db.collection(DBPrefix.received).where('ids', 'array-contains', msg.id).get()).docs;
        // 振り分けメッセージを保持しているユーザを取得
        // ユーザのドキュメントを削除
        for (const j in receivers) {
            const id = receivers[j].id;
            // ドキュメントを削除
            await db.collection(DBPrefix.received).doc(id).collection('messages').doc(msg.id).delete();
            // 振り分けリストから削除
            await db.collection(DBPrefix.received).doc(id).update({
                ids: admin.firestore.FieldValue.arrayRemove(msg.id)
            });
        }
    }

    console.log(`success delete expired posts [${dates.length}]`);
    return;
});

/// 画像保存トリガー
export const convertImage = functions.storage.object().onFinalize(async (object) => {
    
    const fileBucket = object.bucket;
    const filePath = object.name;
    const contentType = object.contentType;

    // contentType, パスが設定されていない場合は特に処理なし
    if (!contentType || !filePath) return;

    // contentTypeがイメージではない場合は処理なし
    if (!contentType.startsWith('image/')) return;

    // ファイル名取得
    const fileName = path.basename(filePath);
    // 既に変換済みのファイルの場合は処理なし
    if (fileName.startsWith('cvd_')) return;

    console.log(`filepath is ${filePath}`);

    // ファイル変換処理を実施
    const rep = await convert.image(fileBucket, filePath, contentType, admin.storage());
    
    // URLが存在しない場合はエラー
    if (rep === null) {
        return;
    }

    // レスポンスからURLを取得
    const url = rep[0];

    // FireStore更新
    if (filePath.startsWith('messages')) {
        // ファイル名からメッセージIDを取得
        const id = fileName.replace(path.extname(fileName), '');
        
        // ファイルURLを更新
        await db.collection(DBPrefix.posted).doc(id).update({
            img: url,
            file: rep[1]
        });
        
        const message = (await db.collection(DBPrefix.posted).doc(id).get()).data() as Message;
        // ファイル配信処理を実施
        await delivery.deliveryMessage(message, db);
    }
    else if (filePath.startsWith('users')) {
        const strs = filePath.split('/');
        const uid = strs[1];
        const fileType = fileName.replace(path.extname(fileName), '');

        // 背景画像の更新の場合
        if (fileType === 'bgimage') {
            await db.collection(DBPrefix.users).doc(uid).update(
                {bgImage: url}
            );
        }
        else {
            await db.collection(DBPrefix.users).doc(uid).update(
                {img: url}
            );
        }
    }
    else if (filePath.startsWith('conversation')) {
        const strs = filePath.split('/');
        const convId = strs[1];
        const repId = fileName.replace(path.extname(fileName), '');

        // リプライメッセージのイメージを更新
        await db.collection(DBPrefix.conversation).doc(convId).collection(DBPrefix.replys).doc(repId).update(
            {
                img: url,
                tmp: false
            }
        );
    }

    console.log('success convert image!');
    return;
});