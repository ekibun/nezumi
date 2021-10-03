import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:nezumi/engine/http.dart';
import 'package:nezumi/generated/l10n.dart';
import 'package:nezumi/page/common/base.dart';
import 'package:nezumi/store/subject.dart';
import 'package:nezumi/engine/engine.dart';
import 'package:nezumi/widget/httpImage.dart';
import 'package:nezumi/widget/ripple.dart';

class SubjectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SubjectPage();
  }
}

class _SubjectPage extends State<SubjectPage> {
  Subject? subjectInfo;
  String? epSite;
  List eps = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      subjectInfo = ModalRoute.of(context)?.settings.arguments as Subject;
      setState(() {
        updateEpisodeList(subjectInfo?.info);
      });
    });
  }

  Completer? _subjectUpdateJob;
  updateSubject() {
    final lastJob = _subjectUpdateJob;
    if (lastJob?.isCompleted == false) lastJob?.completeError("cancel");

    final job = _subjectUpdateJob = Completer();
    final infoSite = subjectInfo?.info;
    final infoId = subjectInfo?.sites[subjectInfo?.info ?? ""];
    if (infoSite == null || infoId == null) return;
    Engine.getSource(infoSite).then((value) async {
      final newInfo =
          await (value["getSubjectInfo"] as JSInvokable).invoke([infoId]);
      if (!job.isCompleted) job.complete(newInfo);
    }).catchError((error) {
      if (job.isCompleted) return;
      job.completeError(error);
    }).whenComplete(() {
      if (job == _subjectUpdateJob) _subjectUpdateJob = null;
    });
    job.future.then((value) {
      setState(() {
        if (value is! Map) return;
        subjectInfo?.merge(Subject(
          name: value["name"],
          summary: value["summary"],
          image: value["image"],
        ));
      });
    }).catchError((error) {
      print("subject update error:\n$error");
    });
  }

  Completer? _episodeListJob;
  updateEpisodeList(String? site) {
    final lastJob = _episodeListJob;
    if (lastJob?.isCompleted == false) lastJob?.completeError("cancel");

    final job = _episodeListJob = Completer();
    final infoId = subjectInfo?.sites[site];
    if (site == null || infoId == null) return;
    epSite = site;
    eps.clear();

    Engine.getSource(site).then((value) async {
      final newInfo =
          await (value["getEpisodeList"] as JSInvokable).invoke([infoId]);
      if (!job.isCompleted) job.complete(newInfo);
    }).catchError((error) {
      if (job.isCompleted) return;
      job.completeError(error);
    });
    job.future.then((value) {
      if (epSite != site) return;
      setState(() {
        eps.addAll(value);
      });
    }).catchError((error, stack) {
      print("episode update error:\n$error\n$stack");
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseFragment(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
        ),
        child: LayoutBuilder(builder: (context, constraint) {
          return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 70),
                    child: Material(
                      clipBehavior: Clip.hardEdge,
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        constraints:
                            BoxConstraints(minHeight: constraint.maxHeight),
                        padding: EdgeInsets.fromLTRB(12, 100, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: _buildPanel(context),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12, 54, 12, 0),
                    child: _buildPanelHeader(context),
                  ),
                ],
              ));
        }),
      ),
    );
  }

  Widget _buildPanelHeader(BuildContext context) {
    final s = S.of(context);
    final isCollected = subjectInfo?.isCollected == true;
    final primaryColor = Theme.of(context).primaryColor;
    return Material(
      color: Colors.transparent,
      child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HttpImage(
              Http.wrapReq(subjectInfo?.image),
              borderRadius: BorderRadius.circular(6),
              width: 100,
              height: 120,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 26),
                  Text(
                    subjectInfo?.name ?? "",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 6),
                  Text(subjectInfo?.info ?? ""),
                ],
              ),
            ),
          ],
        ),
        Ripple(
          onTap: () {
            final subject = subjectInfo;
            if (subject == null) return;
            setState(() {
              SubjectDB().collect(subject, !subject.isCollected);
            });
          },
          borderless: false,
          borderRadius: BorderRadius.circular(1000),
          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
          backgroundColor:
              isCollected ? primaryColor.withAlpha(40) : Colors.black12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCollected ? Icons.favorite : Icons.favorite_outline,
                size: 16,
                color: isCollected ? primaryColor : null,
              ),
              SizedBox(width: 6),
              Text(
                isCollected ? s.Collected : s.Collect,
                style: TextStyle(
                  color: isCollected ? primaryColor : null,
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  // panel
  List<Widget> _buildPanel(BuildContext context) {
    final s = S.of(context);
    return [
      SizedBox(height: 12),
      Text(
        subjectInfo?.summary ?? "",
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
      SizedBox(height: 12),
      Container(height: 1, color: Colors.grey.withOpacity(0.2)),
      Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          s.Episodes,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
      FutureBuilder(
          future: _episodeListJob?.future,
          builder: (_, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else if (snapshot.hasData) {
              return eps.isEmpty
                  ? Text(s.ErrorEmpty)
                  : GridView.builder(
                      clipBehavior: Clip.none,
                      shrinkWrap: true,
                      physics: new NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisExtent: 64,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: _buildEpisodeItem,
                      itemCount: eps.length,
                    );
            }
            return Text(s.Loading);
          }),
    ];
  }

  Widget _buildEpisodeItem(BuildContext context, int index) {
    final item = eps[index];
    return Ripple(
      onTap: () {
        if (item is Map)
          Navigator.of(context).pushNamed(
            "video",
            arguments: item,
          );
      },
      borderless: false,
      borderRadius: BorderRadius.circular(10),
      backgroundColor: Colors.black12,
      width: 200,
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Center(
        child: Text(
          item["name"].toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
