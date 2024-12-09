import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileReceivedMessageView extends StatefulWidget {
  final DateTime date;
  final String fileId;
  final Future<bool> Function(String) onDownloadFile;
  const FileReceivedMessageView({
    super.key,
    required this.date,
    required this.fileId,
    required this.onDownloadFile,
  });

  @override
  State<FileReceivedMessageView> createState() =>
      _FileReceivedMessageViewState();
}

class _FileReceivedMessageViewState extends State<FileReceivedMessageView> {
  String downloadState = '';
  @override
  void initState() {
    super.initState();
  }

  String getText() {
    return '${DateFormat('HH').format(widget.date)}:${DateFormat('mm').format(widget.date)}';
  }

  String getFileName() {
    return widget.fileId.split('|')[1];
  }

  @override
  Widget build(BuildContext context) {
    final fileName = getFileName();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 0.0,
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 1),
          child: Row(children: <Widget>[
            Expanded(
              child: ListTile(
                leading: Icon(Icons.file_copy),
                title: Text('$fileName $downloadState'),
                onTap: () {},
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    setState(() {
                      downloadState = 'downloading...';
                    });
                    var isSuccess =
                        await widget.onDownloadFile.call(widget.fileId);
                    if (isSuccess) {
                      setState(() {
                        downloadState = 'downloaded';
                      });
                    } else {
                      setState(() {
                        downloadState = 'download failed';
                      });
                    }
                  },
                  icon: const Icon(Icons.download),
                  iconSize: 16.0,
                )
              ],
            )
          ])),
    );
  }
}
