import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  late FirebaseRemoteConfig remoteConfig;
  Future<void> setup() async {
    remoteConfig = FirebaseRemoteConfig.instance;
    remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 3),
        minimumFetchInterval: const Duration(minutes: 60)));

    remoteConfig.setDefaults({
      "new_andriod_app_version": "1.13.71",  
      "new_ios_app_version":"3.0.5"
    });

    try {
      await remoteConfig.fetch();
      await remoteConfig.activate();
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }

  String get newAndriodAppVersion => remoteConfig.getString("new_andriod_app_version");
  String get newIosAppVersion => remoteConfig.getString("new_ios_app_version");

  FirebaseRemoteConfig get config => remoteConfig;
}
