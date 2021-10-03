import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ffplay/flutter_ffplay.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:nezumi/engine/engine.dart';
import 'package:nezumi/engine/http.dart';
import 'package:nezumi/io/video.dart';
import 'package:nezumi/store/app.dart';
import 'package:nezumi/store/download.dart';
import 'package:nezumi/widget/actionbar.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  FFMpegContext? _ctx;
  Playback? _playback;
  Map? epInfo;
  String log = "";

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

  Completer? getEpisodeJob;
  getEpisode(Map ep) {
    if (this.getEpisodeJob?.isCompleted == false) {
      this.getEpisodeJob?.completeError("cancel"); // cancel
    }
    setState(() {
      log = "获取视频信息...";
    });
    final getEpisodeJob = this.getEpisodeJob = Completer();
    Engine.getSource(ep["site"]).then((value) async {
      final newInfo = await (value["getEpisode"] as JSInvokable).invoke([ep]);
      if (!getEpisodeJob.isCompleted) getEpisodeJob.complete(newInfo);
    }).catchError((error) {
      if (getEpisodeJob.isCompleted) return;
      getEpisodeJob.completeError(error);
    });
    getEpisodeJob.future.then((value) {
      // print(value);
      _loadVideo(Http.wrapReq(value));
      setState(() {
        log = "获取视频信息...[成功]\n解析视频地址...";
      });
    }).catchError((error) {
      setState(() {
        log = "获取视频信息...[失败]\n$error";
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final ep = epInfo = ModalRoute.of(context)?.settings.arguments as Map;
      getEpisode(ep);
    });
  }

  @override
  void dispose() {
    _ctx?.close();
    _playback?.close();
    super.dispose();
  }

  void _loadVideo(Map req) async {
    if (_ctx != null) {
      final ctx = _ctx;
      _ctx = null;
      await ctx?.close();
    }
    final playback = _playback ??= await Playback.create(onFrame: (pts) {
      setState(() {
        if (pts == null) {
          _isPlaying = false;
        } else {
          _isPlaying = true;
          _position = _isSeeking ? _position : pts;
        }
      });
    });
    final task = DownloadTask(req: req);
    final ioHandler = HttpIOHandler(task);
    final ctx = _ctx = FFMpegContext(
      req["url"] ?? "",
      ioHandler,
      playback,
    );
    final streams = await ctx.getStreams();
    setState(() {
      log = "";
    });
    _duration = await ctx.getDuration();
    await ctx.play(streams);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppSettings.getTheme(true);
    return Theme(
      data: theme,
      child: Material(
        color: Colors.black,
        child: Column(
          children: [
            ActionBar(
              children: [
                Expanded(
                  child: Text(
                    epInfo?["name"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.subtitle1,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  (_playback?.textureId ?? -1) != -1
                      ? Center(
                          child: AspectRatio(
                          aspectRatio: _playback!.aspectRatio,
                          child: Texture(textureId: _playback!.textureId),
                        ))
                      : const SizedBox(),
                  log.isNotEmpty
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(8),
                          color: Colors.black.withAlpha(50),
                          alignment: AlignmentDirectional.bottomStart,
                          child: Text(log),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(width: 6),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () async {
                    _isPlaying ? _ctx?.pause() : _ctx?.resume();
                  },
                ),
                Expanded(
                  child: Slider(
                      value: max(
                          0, min(_position.toDouble(), _duration.toDouble())),
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
                SizedBox(width: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
