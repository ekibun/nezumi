import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ffplay/flutter_ffplay.dart';
import 'package:nezumi/io/video.dart';
import 'package:nezumi/common/download.dart';

class DownloadFragment extends StatefulWidget {
  const DownloadFragment({Key? key}) : super(key: key);

  @override
  _DownloadFragmentState createState() => _DownloadFragmentState();
}

class _DownloadFragmentState extends State<DownloadFragment> {
  final TextEditingController urlController = TextEditingController(
    text: 'http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4',
  );
  final TextEditingController pathController = TextEditingController(
    text: 'test',
  );

  FFMpegContext? _ctx;
  Playback? _playback;

  bool _isPlaying = false;
  int _duration = 0;
  int _position = 0;
  bool _isSeeking = false;

  String parseHHMMSS(int pts) {
    final sec = pts ~/ AV_TIME_BASE;
    final min = sec ~/ 60;
    final hour = min ~/ 60;
    String ret = (min % 60).toString().padLeft(2, '0') +
        ':' +
        (sec % 60).toString().padLeft(2, '0');
    if (hour == 0) return ret;
    return '$hour:$ret';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("url:"),
            Expanded(
              child: TextField(
                controller: urlController,
              ),
            ),
            Text("path:"),
            SizedBox(
              width: 200,
              child: TextField(
                controller: pathController,
              ),
            ),
            TextButton(
              child: const Text("load"),
              onPressed: () async {
                if (_ctx != null) {
                  final ctx = _ctx;
                  _ctx = null;
                  await ctx?.close();
                }
                final url = urlController.text;
                final path = pathController.text;
                final playback =
                    _playback ??= await Playback.create(onFrame: (pts) {
                  setState(() {
                    if (pts == null) {
                      _isPlaying = false;
                    } else {
                      _isPlaying = true;
                      _position = _isSeeking ? _position : pts;
                    }
                  });
                });
                final task = DownloadList().getTask(path, {"url": url});
                final ioHandler = HttpIOHandler(task);
                ioHandler.prefix = path;
                final ctx = _ctx = FFMpegContext(
                  url,
                  ioHandler,
                  playback,
                );
                final streams = await ctx.getStreams();
                _duration = await ctx.getDuration();
                await ctx.play(streams);
                setState(() {});
              },
            )
          ],
        ),
        Expanded(
            child: (_playback?.textureId ?? -1) != -1
                ? Center(
                    child: AspectRatio(
                    aspectRatio: _playback!.aspectRatio,
                    child: Texture(textureId: _playback!.textureId),
                  ))
                : const SizedBox()),
        Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () async {
                _isPlaying ? _ctx?.pause() : _ctx?.resume();
              },
            ),
            Expanded(
              child: Slider(
                  value:
                      max(0, min(_position.toDouble(), _duration.toDouble())),
                  max: max(0, _duration.toDouble()),
                  onChanged: (pos) {
                    _isSeeking = true;
                    setState(() {
                      _position = pos.toInt();
                    });
                  },
                  onChangeEnd: (pos) async {
                    await _ctx?.seekTo(pos.toInt());
                    _isSeeking = false;
                  }),
            ),
            Text(_duration < 0
                ? parseHHMMSS(_position)
                : "${parseHHMMSS(_position)}/${parseHHMMSS(_duration)}"),
            SizedBox(
                width: 200,
                child: Slider(
                    value: _playback?.speedRatio ?? 1,
                    max: 2,
                    min: 0.5,
                    onChanged: (pos) {
                      _playback?.speedRatio = pos;
                    })),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
    // return Padding(
    //   padding: EdgeInsets.fromLTRB(0, 54, 0, 0),
    //   child: TextButton(
    //     child: Text("下载"),
    //     onPressed: () async {
    //       try {
    //         final prefix = "test3";
    //         final url =
    //             "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4";
    //         final task = DownloadList().getTask(prefix, {"url": url});
    //         final ioHandler = HttpIOHandler(task);
    //         ioHandler.prefix = prefix;
    //         final ffmpeg = FFMpegContext(url, ioHandler, null);
    //         await ffmpeg.getStreams();
    //         ffmpeg.play([]);
    //       } catch (e) {}

    //       // list.flush();
    //     },
    //   ),
    // );
    // return ListView.builder(
    //   clipBehavior: Clip.none,
    //   padding: EdgeInsets.fromLTRB(0, 54, 0, 0),
    //   itemBuilder: (context, index) {
    //     final entry = list.data.entries.elementAt(index);
    //     return _buildItem(context, entry.key, entry.value, list);
    //   },
    //   itemCount: list.data.length,
    // );
  }

  // Widget _buildItem(
  //     BuildContext context, String prefix, Map data, DownloadList list) {
  //   return ListTile(
  //     title: Text(prefix),
  //     subtitle: Text(data.toString()),
  //     trailing: ,
  //   );
  // }
}

// class DownloadTask {
//   final Map request;
//   final FileContext file;

//   DownloadTask(this.request, String path, List<int> done)
//       : file = Global.fs.getContext(path, create: true, done: done);
// }
