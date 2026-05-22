import os

with open('lib/main.dart', 'r') as f:
    lines = f.readlines()

def get_block(start_line, end_line):
    return "".join(lines[start_line-1:end_line])

os.makedirs('lib/models', exist_ok=True)
os.makedirs('lib/core', exist_ok=True)
os.makedirs('lib/painters', exist_ok=True)
os.makedirs('lib/widgets', exist_ok=True)
os.makedirs('lib/screens', exist_ok=True)

part_of = "part of '../main.dart';\n\n"

with open('lib/models/models.dart', 'w') as f:
    f.write(part_of)
    f.write(get_block(37, 123))
    f.write(get_block(213, 270))

with open('lib/core/sound_manager.dart', 'w') as f:
    f.write(part_of)
    f.write(get_block(124, 212))

with open('lib/painters/painters.dart', 'w') as f:
    f.write(part_of)
    f.write(get_block(271, 346))
    f.write(get_block(527, 556))
    f.write(get_block(1671, len(lines)))

with open('lib/widgets/widgets.dart', 'w') as f:
    f.write(part_of)
    f.write(get_block(557, 577))
    f.write(get_block(852, 1105))

with open('lib/screens/splash_screen.dart', 'w') as f:
    f.write(part_of)
    f.write(get_block(347, 526))

with open('lib/screens/main_menu_screen.dart', 'w') as f:
    f.write(part_of)
    f.write(get_block(578, 851))

with open('lib/screens/game_screen.dart', 'w') as f:
    f.write(part_of)
    f.write(get_block(1106, 1670))

main_imports = """import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

part 'models/models.dart';
part 'core/sound_manager.dart';
part 'painters/painters.dart';
part 'widgets/widgets.dart';
part 'screens/splash_screen.dart';
part 'screens/main_menu_screen.dart';
part 'screens/game_screen.dart';

"""

with open('lib/main.dart', 'w') as f:
    f.write(main_imports)
    f.write(get_block(8, 36))

print("Split complete!")
