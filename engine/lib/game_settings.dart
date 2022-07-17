class GameSettings {
  // prevent calcMaxResources from taking forever during an ai turn by setting this
  int maxTimeCalcResources = 0; // time in ms
  int maxTimeCalcResourcesAi = 100;
  // Prevent calcMaxResources from taking forever by limiting how many converters
  // a rollout turn will purchase.
  int maxAiRolloutConverters = 5;
  // the ai will run iterations until turn time is up
  int aiTurnIterations = 2500;
  int aiTurnTime = 5000; // time in ms
  // after aiTurnTime expires, the ai will keep playing until one of these is true
  int aiMinVisits = 50;
  int aiTurnTimeCutoff = 10000; // time in ms
  // cap the time each rollout can take
  int maxAiRolloutTime = 100;

  GameSettings();
}
