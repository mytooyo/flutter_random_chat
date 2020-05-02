# Flutter Random Chat

宛先を指定せず、アクティブなユーザに対してランダムにメッセージを送信し、  
チャットを開始するサービスのサンプル  

## Service used
- Flutter
- Firebase (GCP)
    * Authentication
    * Firestore
    * Storage
    * ColudFunctions
    * Vision API

## Screenshots
![Profile](https://github.com/mytooyo/flutter_random_chat/blob/media/profile.gif)
![Activities](https://github.com/mytooyo/flutter_random_chat/blob/media/activities.gif)

## Building the project

Flutter Beta版を利用して開発を行ったため、動作確認する際はBeta版を有効にする必要がある.  
動作確認やソースコードの流用については自己責任でお願いします.

### Flutter Beta
```
$ flutter channel beta
$ flutter upgrade
$ flutter config --enable-web
```

### Set up
1. Firebase Projectの作成および上記Serviceの設定()
2. Android用の`google-services.json`を`app/android/app/src`に配置
3. iOS用の`GoogleService-Info.plist`を`app/ios/Runner`に配置

* FirebaseでAndroidアプリ追加時のパッケージ名、iOSアプリ追加時のバンドルIDは共に`com.exapmle.app`
* iOSのファイルを配置する際はXcodeを開いてファイルを正確にコピーを行わないと読み込まれない場合がある

上記の準備が終了した後、AndroidのエミュレータやiOSのSimulatorを起動して下記コマンドで実行
```
flutter run -d ${device_id}
```

* 実機で確認を行う場合はBundleID等、必要な設定を行う必要がある

