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

### スクリーンショット撮影

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