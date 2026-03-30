import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:beanstalk_mobile/src/pages/dashboard/dashboard_page.dart';
import 'package:beanstalk_mobile/src/pages/dispensary/dispensary_list_page.dart';
import 'package:beanstalk_mobile/src/pages/journal/journal_page.dart';
import 'package:beanstalk_mobile/src/pages/clinicians/clinicians_list_page.dart';

import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

class NavigationApp extends StatefulWidget with WidgetsBindingObserver {
  @override
  _NavigationAppState createState() => _NavigationAppState();
}

class _NavigationAppState extends State<NavigationApp> with WidgetsBindingObserver {
  final _prefs = new UserPreference();

  bool _indexRedirect = false;
  int _selectedIndex = 0;

  final List<Widget> _pageView = [
    DashboardPage(),
    DispensaryListPage(),
    JournalPage(),
    CliniciansListPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print("::");
        print("::RESTORE TIMER : $state");
        print("::");
        if (_prefs.activeSession) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed("session_active");
          });
        }

        break;
      case AppLifecycleState.inactive:
        print(state);
        break;
      case AppLifecycleState.paused:
        print(state);
        break;
      case AppLifecycleState.detached:
        print(state);
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? redirect = ModalRoute.of(context)!.settings.arguments?.toString();
    if (redirect != null && _indexRedirect == false) {
      if (redirect == "dispensaries") {
        _selectedIndex = 1;
      } else if (redirect == "clinicians") {
        _selectedIndex = 3;
      } else {
        _selectedIndex = 0;
      }
      _indexRedirect = false;
      redirect = null;
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColor.background,
        elevation: 10.0,
        unselectedItemColor: AppColor.content.withOpacity(0.9),
        selectedItemColor: AppColor.secondaryColor,
        iconSize: 35.0,
        currentIndex: _selectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
              color: _selectedIndex == 0 ? AppColor.secondaryColor : AppColor.content.withOpacity(0.8),
            ),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.storefront,
                color: _selectedIndex == 1 ? AppColor.secondaryColor : AppColor.content.withOpacity(0.8),
              ),
              label: "Dispensaries"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.library_books_outlined,
                color: _selectedIndex == 2 ? AppColor.secondaryColor : AppColor.content.withOpacity(0.8),
              ),
              label: "My Journal"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.perm_contact_calendar_rounded,
                color: _selectedIndex == 3 ? AppColor.secondaryColor : AppColor.content.withOpacity(0.8),
              ),
              label: "Clinicians")
        ],
        onTap: _onItemTapped,
      ),
      body: _pageView[_selectedIndex],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _indexRedirect = true;
      _selectedIndex = index;
    });
  }
}
