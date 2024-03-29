/// Support for doing something awesome.
///
/// More dartdocs go here.
library engine;

import 'package:logging/logging.dart';
import 'game_settings.dart';

export 'package:logging/logging.dart';

export 'game_settings.dart';
export 'src/action/action.dart';
export 'src/calc_resources.dart';
export 'src/common/common.dart';
export 'src/engine_base.dart';
export 'src/error/invalid_operation_error.dart';
export 'src/game.dart';
export 'src/game_controller.dart';
export 'src/game_object.dart';
export 'src/models/game_model.dart';
export 'src/part/part.dart';
export 'src/player/player.dart';
export 'src/player/player_service.dart';
export 'src/player_data.dart';
export 'src/resource/resource.dart';
export 'src/state/game_state.dart';
export 'src/undo/undo.dart';

final log = Logger("engine");
final gameSettings = GameSettings();
