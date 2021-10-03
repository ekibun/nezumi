import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:nezumi/store/subject.dart';
import 'package:nezumi/engine/engine.dart';
import 'package:nezumi/page/common/subjectList.dart';
import 'package:nezumi/widget/actionbar.dart';
import 'package:nezumi/widget/ripple.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String searchKey = "";
  int searchPage = 0;
  List<Subject> searchResult = [];
  List<Completer> jobs = [];
  String provider = "acfun.cn";

  search(String key, int page) {
    searchPage = page;
    searchKey = key;
    jobs.forEach((element) {
      if (!element.isCompleted) element.completeError("cancel"); // cancel
    });
    jobs.clear();
    searchResult.clear();
    setState(() {});

    var searchJob = Completer<Iterable<Subject>>();
    final site = provider;
    Engine.getSource(site).then((value) async {
      final searchData =
          await (value["search"] as JSInvokable).invoke([key, page]);
      if (searchJob.isCompleted) return;
      if (!(searchData is List)) throw Exception("return data error");
      JSRef.freeRecursive(searchData);
      searchData.forEach((element) {
        (element as Map)["site"] = site;
      });
      if (!searchJob.isCompleted)
        searchJob.complete(searchData.map((e) {
          return Subject(
            name: e["name"]?.toString(),
            image: e["image"],
            summary: e["summary"]?.toString(),
            src: [
              Source(
                site: site,
                id: e["id"]?.toString(),
              )
            ],
          );
        }));
    }).catchError((error, stack) {
      if (searchJob.isCompleted) return;
      searchJob.completeError(error, stack);
    }).whenComplete(() => jobs.remove(searchJob));

    searchJob.future.then((value) async {
      searchResult.addAll(value);
      setState(() {});
    }).catchError((e) {
      print("search error:\n$e");
    });
    jobs.add(searchJob);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(children: [
        SafeArea(
          child: SubjectList(
            searchResult,
            padding: EdgeInsets.fromLTRB(12, 60, 12, 12),
            onTapItem: (subject) async {
              Navigator.of(context).pushNamed("subject", arguments: subject);
            },
          ),
        ),
        GradientBackground(
          child: ActionBar(children: [
            Expanded(
              child: _buildSearchAction(context),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSearchAction(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: Colors.black12,
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Icon(
            Icons.search,
            color: Colors.black38,
          ),
          SizedBox(width: 6),
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: null,
              textInputAction: TextInputAction.search,
              onSubmitted: (key) {
                search(key, 1);
              },
            ),
          ),
          SizedBox(width: 6),
          Container(
            width: 2,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.black38,
            ),
          ),
          Ripple(
            onTap: () {},
            padding: EdgeInsets.all(12),
            borderless: false,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(1000)),
            child: Text(provider),
          ),
        ],
      ),
    );
  }
}
