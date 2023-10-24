# doctool_test

FlutterでS3にファイルをアップロード＆参照するテスト
アクセス制御を入れるためにS3とのやり取りはFastAPIサーバーを経由する

## 起動方法

```
make up
```

## 参考ページ

### app(Flutter)

- [Flutter Web AppをAWS CDKでCloudFront+S3にデプロイしてみた | DevelopersIO](https://dev.classmethod.jp/articles/deploying-the-flutter-app-web-to-cloudfronts3-with-aws-cdk/)
- [How to Build a Simple Login App with Flutter](https://www.freecodecamp.org/news/how-to-build-a-simple-login-app-with-flutter/)
- [Flutter Implement Login with Rest APIS | by Axiftaj | Medium](https://axiftaj.medium.com/flutter-implement-login-with-rest-apis-6857b356d08c)
- [Send data to the internet | Flutter](https://docs.flutter.dev/cookbook/networking/send-data)
- [FlutterでJWT認証を行う](https://zenn.dev/joo_hashi/articles/7887a9348ca244)
- [Flutterで端末内のファイルを読み込むfile_picker | Taro3se](https://taro3se.com/p/279)
- [Flutterでdotenvを利用して環境変数を管理する方法 | DevelopersIO](https://dev.classmethod.jp/articles/flutter-dotenv/)

### API(FastAPI)

- [FastAPI入門](https://zenn.dev/sh0nk/books/537bb028709ab9)
- [MinIOをboto3を使ってPythonから操作する - よしたく blog](https://yoshitaku-jp.hatenablog.com/entry/2022/04/29/130000)
- [docker-composeでMinIO(S3互換)環境簡単構築 #Docker - Qiita](https://qiita.com/A-Kira/items/5bb9b3108ba12f533e49)
