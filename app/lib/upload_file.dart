import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

const signer = AWSSigV4Signer(
  credentialsProvider: AWSCredentialsProvider(
      AWSCredentials("YOUR AWS ACCESS KEY ID", "YOUR AWS SECRET KEY")),
);

// Set up S3 values
const region = 'ap-northeast-1';
const bucket = 'YOUR BUCKET NAME';
const host = '$bucket.s3.$region.amazonaws.com';
final scope = AWSCredentialScope(
  region: region,
  service: AWSService.s3,
);
final serviceConfiguration = S3ServiceConfiguration();

Future<void> uploadFile(String filename) async {
  final file = File(filename).openRead();
  final path = '/${p.basename(filename)}';
  final request = AWSStreamedHttpRequest.put(
    Uri.https(host, path),
    body: file,
    headers: {
      AWSHeaders.host: host,
      AWSHeaders.contentType: 'text/plain',
    },
  );

  stdout.writeln('Uploading file $filename to $path...');
  final signedRequest = await signer.sign(
    request,
    credentialScope: scope,
    serviceConfiguration: serviceConfiguration,
  );
  final uploadResponse = await signedRequest.send().response;
  final uploadStatus = uploadResponse.statusCode;
  stdout.writeln('Upload File Response: $uploadStatus');
  if (uploadStatus != 200) {
    exitWithError('Could not upload file');
  }
  stdout.writeln('File uploaded successfully!');
}

/// Exits the script with an [error].
Never exitWithError(String error) {
  stderr.writeln(error);
  exit(1);
}
