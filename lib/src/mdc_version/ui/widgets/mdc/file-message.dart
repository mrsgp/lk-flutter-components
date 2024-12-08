import 'dart:math';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livekit_components/src/mdc_version/context/chat_context.dart';

class FileTransferMessageView extends StatefulWidget {
  final ChatMessage chatMessage;
  final Future<String> Function(XFile) onUploadFile;
  final Function(String, String) onUploadCompleted;
  final Function(String) onCancelUploadCallback;

  const FileTransferMessageView(
      {super.key,
      required this.chatMessage,
      required this.onUploadFile,
      required this.onCancelUploadCallback,
      required this.onUploadCompleted});

  @override
  State<FileTransferMessageView> createState() =>
      _FileTransferMessageViewState();
}

class _FileTransferMessageViewState extends State<FileTransferMessageView> {
  String fileSize = '0 B';
  String uploadState = '';
  late XFile file;
  late String msgId;
  @override
  void initState() {
    super.initState();
    file = widget.chatMessage.message as XFile;
    msgId = widget.chatMessage.id;
    () async {
      var fileLength = await file.length();

      setState(() {
        fileSize = _formatFileSize(fileLength);
      });
    }();
  }

  String _formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  String getText() {
    var date =
        DateTime.fromMillisecondsSinceEpoch(widget.chatMessage.timestamp);
    return '${DateFormat('HH').format(date)}:${DateFormat('mm').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 0.0,
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 1),
          child: Row(children: <Widget>[
            Expanded(
              child: ListTile(
                title: Text(file.name),
                subtitle: Text('$fileSize $uploadState'),
                onTap: () {},
              ),
            ),
            if (uploadState == 'uploading')
              const Icon(Icons.loop)
            else if (uploadState == 'completed' || widget.chatMessage.alreadyUploaded)
              const Icon(
                Icons.check,
                color: Colors.green,
              )
            else if (uploadState == 'error')
              const Icon(
                Icons.error,
                color: Colors.red,
              )
            else
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        uploadState = 'uploading';
                      });
                      var remoteFileName = await widget.onUploadFile(file);
      
                      if (remoteFileName != '') {
                        widget.onUploadCompleted.call(
                          remoteFileName, msgId
                        );
                        setState(() {
                          uploadState = 'completed';
                        });
                      } else {
                        setState(() {
                          uploadState = 'error uploading file';
                        });
                      }
                    },
                    icon: const Icon(Icons.cloud_upload),
                    iconSize: 16.0,
                  ),
                  IconButton(
                    color: Colors.red,
                    onPressed: () {
                      widget.onCancelUploadCallback.call(widget.chatMessage.id);
                    },
                    icon: const Icon(Icons.cancel),
                    iconSize: 16.0,
                  )
                ],
              )
          ])),
    );
  }
}
