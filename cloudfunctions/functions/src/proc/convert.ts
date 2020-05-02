import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import * as admin from 'firebase-admin';
import { spawn } from 'child-process-promise';
import * as vision from '@google-cloud/vision';

const noallowed = [
    "VERY_LIKELY",
    "LIKELY",
];

export async function image(fileBucket: string, filePath: string, contentType: string, storage: admin.storage.Storage) {

    // ファイル名取得
    const fileName = path.basename(filePath);
    
    // 変換後ファイル名
    const convertedFileName = `cvd_${fileName}`;
    
    const bucket = storage.bucket(fileBucket);

    // 登録された画像の検証を行う
    const client = new vision.ImageAnnotatorClient();
    const gsPath = `gs://${fileBucket}/${filePath}`;
    const res = await client.safeSearchDetection(gsPath);

    if (res[0].safeSearchAnnotation !== null) {
        console.log(`vision api: ${res[0].safeSearchAnnotation?.adult?.toString()}`);

        // アダルトの要素が存在する場合
        const adult = res[0].safeSearchAnnotation?.adult?.toString() ?? '';
        if (noallowed.indexOf(adult) >= 0) return null;

        // 暴力的な描写の要素が存在する場合
        const violence = res[0].safeSearchAnnotation?.violence?.toString() ?? '';
        if (noallowed.indexOf(violence) >= 0) return null;

    }


    // TEMPファイル生成
    const tempDownloadFilePath = path.join(os.tmpdir(), fileName);
    // const tempConvertedFilePath = path.join(os.tmpdir(), convertedFileName);
    const metadata = {
        contentType,
        resumable: false,
        autoOrient: true
    };

    // 登録されたファイルをTEMPファイル名としてダウンロード
    await bucket.file(filePath).download({ destination: tempDownloadFilePath });
    console.log('Image downloaded locally to', tempDownloadFilePath);

    // 向きを自動で修正
    await spawn('convert', [
        tempDownloadFilePath,
        '-auto-orient',
        tempDownloadFilePath
    ])

    // 変換後のファイルパス生成
    const convertedFilePath = path.join(path.dirname(filePath), convertedFileName);

    // 既に同一のファイルが存在する場合は一旦削除
    
    // const exists = await bucket.file(tempConvertedFilePath).exists();
    // console.log('converted file is exists', exists);
    // if (exists) await bucket.file(convertedFilePath).delete();

    // 新しいイメージを登録
    await bucket.upload(tempDownloadFilePath, {
        destination: convertedFilePath,
        resumable: false,
        metadata: {metadata: metadata}
    });
    console.log('uploaded converted file ', convertedFilePath);

    // TEMPファイルを削除してディスクスペースを確保
    fs.unlinkSync(tempDownloadFilePath);
    // fs.unlinkSync(tempConvertedFilePath);

    // 変換前の画像は不要のため削除
    await bucket.file(filePath).delete();

    // ファイルダウンロード用のURLを返却
    return [
        `https://firebasestorage.googleapis.com/v0/b/${fileBucket}/o/${encodeURIComponent(convertedFilePath)}?alt=media`,
        convertedFileName
    ];
}