import 'package:engine/engine.dart';
//import 'package:shared_preferences/shared_preferences.dart';

// some settings are stored in the engine in GameSettings
// this class manages settings for the GUI, and provides the
// interface for updating GameSettings
class FMSettings {
  FMSettings();

  Future<void> updateFromPrefs() async {
    // Obtain shared preferences.
    // final prefs = await SharedPreferences.getInstance();

    // gameSettings
    //   ..maxTimeCalcResourcesAi = prefs.getInt('maxTimeCalcResourcesAi') ?? gameSettings.maxTimeCalcResourcesAi
    //   ..maxAiRolloutConverters = prefs.getInt('maxAiRolloutConverters') ?? gameSettings.maxAiRolloutConverters
    //   ..aiTurnIterations = prefs.getInt('aiTurnIterations') ?? gameSettings.aiTurnIterations
    //   ..aiTurnTime = prefs.getInt('aiTurnTime') ?? gameSettings.aiTurnTime
    //   ..aiMinVisits = prefs.getInt('aiMinVisits') ?? gameSettings.aiMinVisits
    //   ..aiTurnTimeCutoff = prefs.getInt('aiTurnTimeCutoff') ?? gameSettings.aiTurnTimeCutoff
    //   ..maxAiRolloutTime = prefs.getInt('maxAiRolloutTime') ?? gameSettings.maxAiRolloutTime;
  }

  Future<void> saveToPrefs() async {
    // final prefs = await SharedPreferences.getInstance();

    // prefs.setInt('maxTimeCalcResourcesAi', gameSettings.maxTimeCalcResourcesAi);
    // prefs.setInt('maxAiRolloutConverters', gameSettings.maxAiRolloutConverters);
    // prefs.setInt('aiTurnIterations', gameSettings.aiTurnIterations);
    // prefs.setInt('aiTurnTime', gameSettings.aiTurnTime);
    // prefs.setInt('aiMinVisits', gameSettings.aiMinVisits);
    // prefs.setInt('aiTurnTimeCutoff', gameSettings.aiTurnTimeCutoff);
    // prefs.setInt('maxAiRolloutTime', gameSettings.maxAiRolloutTime);
  }
}
