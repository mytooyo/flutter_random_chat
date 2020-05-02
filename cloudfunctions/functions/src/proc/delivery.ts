import { DBPrefix, User, Message } from '../models';
import { firestore } from 'firebase-admin';

// 最大の送信対象件数
const max = 20;

export async function deliveryMessage(msg: Message, db: FirebaseFirestore.Firestore) {

    // 登録されているユーザ一覧を取得
    const datas = (await db.collection(DBPrefix.users).where('available', '==', true).get()).docs;
    
    // 送信対象のユーザIDリスト
    const uids: string[] = [];
                
    // 最大送信件数と登録されているユーザの件数で小さい方を取得
    // (ユーザ件数は自分を除くため、-1)
    var count = Math.min(max, datas.length - 1);
    
    // 0以下の場合は自分しかいないため処理なし
    if (count <= 0 ) return;

    // 指定件数分処理を行う
    while(uids.length < count) {
        // ランダムでインデックスを取得
        const index = Math.floor(Math.random() * datas.length);
        // 取得したインデックスのユーザ情報を取得
        const user = datas[index].data() as User;

        // 拒否リストが存在し、送信元が拒否対象の場合は割り振らない
        // if (user.refusal !== null && user.refusal.indexOf(msg.uid) >= 0) {
        //     count -= 1;
        //     continue;
        // }
        
        // 既に登録済みのUIDまたは自分自身のUIDの場合は処理なし
        if (uids.indexOf(user.id) < 0 && user.id !== msg.from.id) {
            uids.push(user.id);
        }
    }

    // 基本的にこんなことはここでありえないが、次以降の処理で落ちたら
    // 嫌なので、とりあえずチェック処理をいれておく
    if (uids.length === 0) return;

    // 取得したUID分の処理を実施
    for(const i in uids) {

        // 一旦枠をここで作成しておく
        await db.collection(DBPrefix.received).doc(`${uids[i]}`).set(
            {timestamp: (new Date()).getTime()},
            {merge: true}
        );

        // Firestoreのコレクションにユーザ毎のドキュメントを作成して登録
        await db.collection(DBPrefix.received).doc(`${uids[i]}`).collection('messages').doc(`${msg.id}`).set({
            id: msg.id,
            img: msg.img,
            message: msg.message,
            uid: msg.uid,
            timestamp: msg.timestamp,
            from: {
                id: msg.from.id,
                name: msg.from.name,
                img: msg.from.img,
                bgImage: msg.from.bgImage,
                profile: msg.from.profile,
                lang: msg.from.lang,
                age: msg.from.age,
                available: msg.from.available,
                timestamp: msg.from.timestamp
            }
        });

        await db.collection(DBPrefix.received).doc(`${uids[i]}`).update(
            {ids: firestore.FieldValue.arrayUnion(msg.id)}
        );
    }

    return;
    
}

