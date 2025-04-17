// Yabai key as sway/i3
// references:
// https://github.com/koekeishiya/yabai/blob/c456566e94f2269ae27327039fe7cf4783d8c5a7/doc/yabai.asciidoc
local apps = import 'applications.libsonnet';
local base = import 'base.libsonnet';
local rules = import 'rules.libsonnet';

local mod = 'command';
local yabai = '/opt/homebrew/bin/yabai';

local name = 'Yabai';
local makeName(description) = '%s-%s' % [name, description];

local shellCommand(key, mods=[], command=null, descr='Send Yabai command') = rules.manipulator(
  description=descr,
  from={
    key_code: key,
    modifiers: { mandatory: mods },
  },
  to=[{ shell_command: '%s' % command }],
  conditions=apps.conditions.isNot.emulation
);
local yabaiCommand(key, mods=[], command=null, descr='Send Yabai command') = shellCommand(
  key, mods=mods, command='%s %s' % [yabai, command], descr=descr
);

local workspaces = rules.rule(description='Change workspace',
                              manipulators=std.flattenArrays([
                                [
                                  yabaiCommand('%s' % index, mods=[mod], command='-m space --focus %d' % index),
                                ]
                                for index in std.range(0, 9)
                              ]));
local workspacesMoveTo = rules.rule(description='Move app to workspace',
                                    manipulators=std.flattenArrays([
                                      [
                                        yabaiCommand('%s' % index, mods=[mod, 'shift'], command='-m window --space %d' % index),
                                      ]
                                      for index in std.range(0, 9)
                                    ]));
local layout = rules.rule(description='Set workspace layout',
                          manipulators=[
                            yabaiCommand('e', mods=[mod], command='-m space --layout bsp'),
                            yabaiCommand('s', mods=[mod], command='-m space --layout stack'),
                            yabaiCommand('w', mods=[mod], command='-m space --layout stack'),
                          ]);
local windowNext = '%(yabai)s -m query --spaces --space | jq -re ".index" | xargs -I{} %(yabai)s -m query --windows --space {} | jq -sre "add | map(select(."is-minimized" != 1)) | sort_by(.display, .frame.y, .frame.x, .id) | reverse | nth(index(map(select(."has-focus" == true))) -1 ).id" | xargs -I{} %(yabai)s -m window --focus {}' % { yabai: yabai };
local windowPrev = '%(yabai)s -m query --spaces --space | jq -re ".index" | xargs -I{} %(yabai)s -m query --windows --space {} | jq -sre "add | map(select(."is-minimized" != 1)) | sort_by(.display, .frame.y, .frame.x, .id) | nth(index(map(select(."has-focus" == true))) -1 ).id" | xargs -I{} %(yabai)s -m window --focus {}' % { yabai: yabai };
local windowFocus = rules.rule(description='Move windows focus',
                               manipulators=[
                                 shellCommand('up_arrow', mods=[mod], command='%(yabai)s -m window --focus north || %(yabai)s -m window --focus stack.first' % { yabai: yabai }),
                                 shellCommand('down_arrow', mods=[mod], command='%(yabai)s -m window --focus south || %(yabai)s -m window --focus stack.last' % { yabai: yabai }),
                                 shellCommand('left_arrow', mods=[mod], command='%(yabai)s -m window --focus west || %(yabai)s -m window --focus stack.prev' % { yabai: yabai }),
                                 shellCommand('right_arrow', mods=[mod], command='%(yabai)s -m window --focus east || %(yabai)s -m window --focus stack.next' % { yabai: yabai }),
                                 shellCommand('comma', mods=[mod], command=windowNext),
                                 shellCommand('period', mods=[mod], command=windowPrev),
                               ]);
local windowMove = rules.rule(description='Move windows on display',
                              manipulators=[
                                yabaiCommand('up_arrow', mods=[mod, 'shift'], command='-m window --swap north'),
                                yabaiCommand('down_arrow', mods=[mod, 'shift'], command='-m window --swap south'),
                                yabaiCommand('left_arrow', mods=[mod, 'shift'], command='-m window --swap west'),
                                yabaiCommand('right_arrow', mods=[mod, 'shift'], command='-m window --swap east'),
                              ]);
local windowClose = rules.rule(description='Close/quit window',
                               manipulators=[
                                 yabaiCommand('q', mods=[mod, 'shift'], command='-m window --close'),
                               ]);
local toggleFullScreen = rules.rule(description='Toggle full screen',
                                    manipulators=[
                                      yabaiCommand('f', mods=[mod], command='-m window --toggle zoom-fullscreen'),
                                    ]);
local yabaiRestart = rules.rule(description='Yabai restart',
                                manipulators=[
                                  yabaiCommand('c', mods=[mod, 'shift'], command='--restart-service'),
                                ]);
local lockScreen = rules.rule(description='lock screen',
                              manipulators=[
                                shellCommand('l', mods=[mod, 'control'], command="osascript -e 'tell application \"System Events\" to keystroke \"q\" using {command down,control down}'"),
                              ]);
local screenMove = rules.rule(description='move screen to other monitor',
                              manipulators=[
                                yabaiCommand('left_arrow', mods=[mod, 'shift', 'control'], command='-m space --display 1'),
                                yabaiCommand('right_arrow', mods=[mod, 'shift', 'control'], command='-m space --display 2'),
                              ]);

local yabai = base.complexModification(title=makeName('Yabai rules'));

//#change focus between external displays (left and right)
//yabai -m display --focus west
//yabai -m display --focus east

// Move Window Within Space And Split
// ctrl + alt - j : yabai -m window --warp south
// ctrl + alt - k : yabai -m window --warp north
// ctrl + alt - h : yabai -m window --warp west
// ctrl + alt - l : yabai -m window --warp east

yabai +
yabai.withRule(workspaces) +
yabai.withRule(workspacesMoveTo) +
yabai.withRule(layout) +
yabai.withRule(windowFocus) +
yabai.withRule(windowMove) +
yabai.withRule(toggleFullScreen) +
yabai.withRule(windowClose) +
yabai.withRule(yabaiRestart) +
yabai.withRule(lockScreen) +
yabai.withRule(screenMove)

//ctrl - e : yabai -m space --layout bsp
//ctrl - s : yabai -m space --layout stack
//
//ctrl - down : yabai -m window --focus stack.next || yabai -m window --focus south
//ctrl - up : yabai -m window --focus stack.prev || yabai -m window --focus north
//ctrl + alt - left : yabai -m window --focus west
//ctrl + alt - right : yabai -m window --focus east
//
//ctrl - f : yabai -m window --toggle float
