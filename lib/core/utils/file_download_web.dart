
import 'dart:html' as html;

void downloadFileWeb(List<int> bytes, String fileName) {
  final blob = html.Blob([bytes]);
  final fileUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: fileUrl)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(fileUrl);
}

void openFileWeb(List<int> bytes, String mimeType) {
  final blob = html.Blob([bytes], mimeType);
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(blobUrl, '_blank');
  html.Url.revokeObjectUrl(blobUrl);
}