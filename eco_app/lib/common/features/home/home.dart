import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/features/scanner_and_monitor/scanner_and_monitor.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const String uri =
      'https://www.nytimes.com/topic/subject/air-pollution';

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(uri));

  static const List<Widget> widgetOptions = <Widget>[
    SizedBox(),
    ScannerAndMonitorPage(),
    Center(
      child: Text("Household Page"),
    ),
  ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isKeyboardShowing = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        color: selectedIndex == 1
            ? context.theme.green
            : context.theme.backgroundColor,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: selectedIndex == 0
            ? homePage(context)
            : widgetOptions[selectedIndex],
      ),
      bottomNavigationBar: isKeyboardShowing
          ? const SizedBox.shrink()
          : Container(
              decoration: BoxDecoration(
                color: context.theme.modalBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: context.theme.greyColor!.withOpacity(0.8),
                    spreadRadius: 1,
                    offset: const Offset(3, 0),
                    blurRadius: 5,
                  ),
                ],
              ),
              // color: const Color(0xFFDFE2F4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GNav(
                  gap: 8,
                  color: Colors.grey[800],
                  activeColor: CommonColors.darkGreen,
                  iconSize: 28,
                  tabBackgroundColor: CommonColors.darkGreen.withOpacity(0.1),
                  // backgroundColor: const Color(0xFFDFE2F4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  duration: const Duration(milliseconds: 500),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.darkGreen,
                  ),
                  tabs: [
                    GButton(
                      icon: selectedIndex == 0
                          ? FontAwesomeIcons.houseUser
                          : FontAwesomeIcons.house,
                      text: 'Home',
                    ),
                    GButton(
                      icon: selectedIndex == 1
                          ? FontAwesomeIcons.calendarWeek
                          : FontAwesomeIcons.calendar,
                      text: 'S&M',
                    ),
                    GButton(
                      icon: selectedIndex == 2
                          ? FontAwesomeIcons.gears
                          : FontAwesomeIcons.gear,
                      text: 'Household',
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
    );
  }

  Padding homePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: WebViewWidget(controller: controller),
    );
  }
}
