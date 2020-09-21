# dotlive-schedule-client

[.スケジュール](https://apps.apple.com/jp/app/%E3%82%B9%E3%82%B1%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB/id1512712289?mt=8)のクライアント  
https://dotlive-schedule.appspot.com/



サーバー:[yaegaki/dotlive-schedule-server](https://github.com/yaegaki/dotlive-schedule-server)

## ビルド方法 

firebaseのコンソールからAndroid用とiOS用に`google-services.json`と`GooogleService-Info.plist`を取得する。  
取得したファイルをそれぞれ以下の場所に配置する。

```sh
# google-services.json
android\app

# GoogleService-Info.plist
ios\Runner
```

デフォルトでは`https://dotlive-schedule.appspot.com`に接続するようになっているので他のサーバーに接続したい場合は`lib\constants.dart`を書き換える。

```patch
- const baseURL = "https://dotlive-schedule.appspot.com";
+ const baseURL = "http://xxx.xxx.xxx.xxx:8080";
```


後は`flutter build`でビルドできる。

## リリース時作業

iOS:[Build and release an iOS app](https://flutter.dev/docs/deployment/ios)  
Android:[Build and release an Android app](https://flutter.dev/docs/deployment/android)  

### バージョン更新

`pubspec.yaml`のバージョンを更新する。  

#### iOS

XCodeでバージョンビルドの更新は手動で行う。  
バージョンを変更する際はウィジェットも変更する。  

### リリースビルド作成

#### iOS

```sh
$ flutter clean
$ flutter build ios
```

#### Android

```sh
$ flutter clean
$ flutter build appbundle
```

ビルドしたappbundleのテストは[bundletool](https://github.com/google/bundletool)を使用する。

```sh 
# ビルド
$ java -jar bundletool-all-1.2.0.jar build-apks --bundle=build\app\outputs\bundle\release\app-release.aab --output=out.apks --ks=PATH_TO_KEYSTORE --ks-key-alias=KEY_ALIAS --ks-pass=pass:KEYSTORE_PASS --key-pass=pass:KEY_PASS --overwrite

# インストール
$ java -jar bundletool-all-1.2.0.jar install-apks --apks=out.apks --device-id=DEVICE_ID
```

### スクリーンショット撮影

#### iOS

以下のコマンドでステータスバーを変更して撮影する。  

```sh
$ xcrun simctl status_bar "iPhone 8 Plus" override \
  --time "0:46" \
  --dataNetwork 4g \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState discharging \
  --batteryLevel 100
```

必要な端末は以下の通り

* iPhone 8 Plus
* iPhone 11 Pro Max
* iPad Pro (12.9-inch) (2nd generation)
* iPad Pro (12.9-inch) (3rd generation)

#### Android

```sh
# デモモード
$ adb shell am broadcast -a com.android.systemui.demo -e command enter

# wifi,通知,時間の設定
$ adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4
$ adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
$ adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0406

# デモモード終了
$ adb shell am broadcast -a com.android.systemui.demo -e command exit
```