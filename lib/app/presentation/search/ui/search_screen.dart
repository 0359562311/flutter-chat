import 'dart:math';

import 'package:chat/app/presentation/search/provider/search_provider.dart';
import 'package:chat/core/const/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SearchProvider _provider = SearchProvider();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 2,
        backgroundColor: Colors.white,
        title: TextField(
          decoration: const InputDecoration(
            hintText: "Search",
          ),
          onChanged: _provider.search,
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: _provider,
        builder: (context, _) {
          final p = Provider.of<SearchProvider>(context);
          return ListView.builder(
            itemBuilder: (context, index) {
              final u = p.data[index];
              return InkWell(
                onTap: () async {
                  final res = await p.createConversation(u.id);
                  if(res != null) {
                    Navigator.popAndPushNamed(context, AppRoute.conversation, arguments: res);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: (u.avatar == null
                                ? const AssetImage(r"assets/images/person.png")
                                : NetworkImage(u.avatar!)) as ImageProvider,
                          ),
                          if(u.isOnline)
                            Positioned(
                              top: 25 + 20/sqrt(2),
                              left: 25 + 20/sqrt(2),
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle
                                ),
                              ),
                            )
                        ]
                      ),
                      const SizedBox(width: 16,),
                      Text(u.username),
                    ],
                  ),
                ),
              );
            },
            itemCount: p.data.length,
          );
        },
      ),
    );
  }
}
