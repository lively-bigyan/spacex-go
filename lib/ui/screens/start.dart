import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/company.dart';
import '../../models/home.dart';
import '../../models/info_vehicle.dart';
import '../../models/launch.dart';
import '../../widgets/dialog_patreon.dart';
import '../tabs/company.dart';
import '../tabs/home.dart';
import '../tabs/launches.dart';
import '../tabs/vehicles.dart';

/// START SCREEN
/// This view holds all tabs & its models: home, vehicles, upcoming & latest launches, & company tabs.
class StartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentIndex = 0;

  @override
  initState() {
    super.initState();

    // Reading app shortcuts input
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((type) {
      switch (type) {
        case 'vehicles':
          setState(() => _currentIndex = 1);
          break;
        case 'upcoming':
          setState(() => _currentIndex = 2);
          break;
        case 'latest':
          setState(() => _currentIndex = 3);
          break;
        default:
          setState(() => _currentIndex = 0);
      }
    });

    Future.delayed(Duration.zero, () async {
      // Show the Patreon's page
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // First time app boots
      if (prefs.getBool('patreon_seen') == null)
        prefs.setBool('patreon_seen', false);
      if (prefs.getString('patreon_date') == null)
        prefs.setString(
          'patreon_date',
          DateTime.now().toIso8601String(),
        );

      // If it's time to show the dialog
      if (!prefs.getBool('patreon_seen') &&
          DateTime.now().isAfter(
            DateTime.parse(prefs.getString('patreon_date')),
          )) {
        showDialog(context: context, builder: (context) => PatreonDialog())
            .then((result) {
          // Then, we'll analize what happened
          if (!(result ?? false))
            prefs.setString(
              'patreon_date',
              DateTime.now().add(Duration(days: 14)).toIso8601String(),
            );
          else
            prefs.setBool('patreon_seen', true);
        });
      }

      // Setting app shortcuts
      quickActions.setShortcutItems(<ShortcutItem>[
        ShortcutItem(
          type: 'vehicles',
          localizedTitle: FlutterI18n.translate(
            context,
            'spacex.vehicle.icon',
          ),
          icon: 'action_vehicle',
        ),
        ShortcutItem(
          type: 'upcoming',
          localizedTitle: FlutterI18n.translate(
            context,
            'spacex.upcoming.icon',
          ),
          icon: 'action_upcoming',
        ),
        ShortcutItem(
          type: 'latest',
          localizedTitle: FlutterI18n.translate(
            context,
            'spacex.latest.icon',
          ),
          icon: 'action_latest',
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<SingleChildCloneableWidget> _models = [
      ChangeNotifierProvider(
        builder: (_) => HomeModel(context),
        child: HomeTab(),
      ),
      ChangeNotifierProvider(
        builder: (_) => VehiclesModel(),
        child: VehiclesTab(),
      ),
      ChangeNotifierProvider(
        builder: (_) => LaunchesModel(Launches.upcoming),
        child: LaunchesTab(Launches.upcoming),
      ),
      ChangeNotifierProvider(
        builder: (_) => LaunchesModel(Launches.latest),
        child: LaunchesTab(Launches.latest),
      ),
      ChangeNotifierProvider(
        builder: (_) => CompanyModel(),
        child: CompanyTab(),
      ),
    ];

    return MultiProvider(
      providers: _models,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _models),
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: TextStyle(fontFamily: 'ProductSans'),
          unselectedLabelStyle: TextStyle(fontFamily: 'ProductSans'),
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          currentIndex: _currentIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              title: Text(FlutterI18n.translate(
                context,
                'spacex.home.icon',
              )),
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              title: Text(FlutterI18n.translate(
                context,
                'spacex.vehicle.icon',
              )),
              icon: Icon(FontAwesomeIcons.rocket),
            ),
            BottomNavigationBarItem(
              title: Text(FlutterI18n.translate(
                context,
                'spacex.upcoming.icon',
              )),
              icon: Icon(Icons.access_time),
            ),
            BottomNavigationBarItem(
              title: Text(FlutterI18n.translate(
                context,
                'spacex.latest.icon',
              )),
              icon: Icon(Icons.library_books),
            ),
            BottomNavigationBarItem(
              title: Text(FlutterI18n.translate(
                context,
                'spacex.company.icon',
              )),
              icon: Icon(Icons.location_city),
            ),
          ],
        ),
      ),
    );
  }
}
