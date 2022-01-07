import 'package:chat/app/presentation/home/bloc/home_bloc.dart';
import 'package:chat/app/presentation/home/bloc/home_state.dart';
import 'package:chat/app/presentation/list_conversations/ui/list_conversations.dart';
import 'package:chat/core/custom_widget/custom_circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  List<Widget> _body = [];

  late final HomeBloc _bloc;
  final _listConversationsKey = GlobalKey<ListConversationsScreenState>();

  @override
  void initState() {
    super.initState();
    _body = [ListConversationsScreen(key: _listConversationsKey,), Container()];
    _bloc = GetIt.I();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HomeState>(
        stream: _bloc.stateStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data is HomeLoadingState) {
            return const CustomCircularProgress();
          } else if (snapshot.data is HomeErrorState) {
            return Text((snapshot.data as HomeErrorState).message);
          }
          return Scaffold(
            appBar: AppBar(
              leading: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: const CircleAvatar(
                  backgroundImage: AssetImage(r"assets/images/messenger.png"),
                ),
                width: 20,
                height: 20,
              ),
              centerTitle: false,
              title: Text(
                _currentIndex == 0 ? "Chats":"People",
                style:
                    const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              elevation: 0.5,
              actions: [
                if (_currentIndex == 0)
                  IconButton(
                      onPressed: () {
                        // TODO: on add new conversation
                      },
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.black,
                      )),
                if (_currentIndex == 0)
                  IconButton(
                      onPressed: () {
                        _listConversationsKey.currentState?.reload();
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.black,
                      )),
              ],
            ),
            body: IndexedStack(
              children: _body,
              index: _currentIndex,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedIconTheme: IconThemeData(color: Colors.blue.shade700),
              onTap: (value) {
                if (value != _currentIndex) {
                  setState(() {
                    _currentIndex = value;
                  });
                }
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.message_rounded), label: "Chats"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline), label: "People"),
              ],
            ),
          );
        });
  }
}
