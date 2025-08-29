import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shareanything/Provider/file_share_provider.dart';
import 'package:shareanything/Provider/private_messages_provider.dart';
import 'package:shareanything/Provider/public_messages_provider.dart';
import 'package:shareanything/Provider/side_bar_provide.dart';
import 'package:shareanything/SideBar/side_bar_page.dart';
import 'package:shareanything/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject(AppConfig.ProjectId);
  final account = Account(client);

  try {
    await account.createAnonymousSession();
    debugPrint("✅ Anonymous session created");
  } catch (e) {
    debugPrint("⚠️ Anonymous session may already exist: $e");
  }
  final storage = Storage(client);
  final databases = Databases(client);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PublicMessagesProvider(databases),
        ),
        ChangeNotifierProvider(
          create: (_) => PrivateMessagesProvider(databases),
        ),
        ChangeNotifierProvider(
          create: (_) => FileShareProvider(client, databases, storage),
        ),
        ChangeNotifierProvider(create: (_) => SideBarProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SideBarPage());
  }
}
