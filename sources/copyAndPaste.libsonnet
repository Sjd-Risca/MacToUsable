local apps = import 'applications.libsonnet';
local base = import 'base.libsonnet';
local rules = import 'rules.libsonnet';

local name = 'ALaLinux';
local makeName(description) = '%s-%s' % [name, description];

local ctlToCommand(key, descr='Override ctl to command') = rules.manipulator(
  description=descr,
  from={
    key_code: key,
    modifiers: { mandatory: ['control'] },
  },
  to={
    modifiers: ['command'],
    key_code: key,
  },
  conditions=apps.conditions.isNot.terminal
);
local ctlShiftToCommand(key, descr='Override ctl shift to command') = rules.manipulator(
  description=descr,
  from={
    key_code: key,
    modifiers: { mandatory: ['control', 'shift'] },
  },
  to={
    modifiers: ['command'],
    key_code: key,
  },
  conditions=apps.conditions.is.terminal
);

local unsetCommand(key, descr='Unset command') = rules.manipulator(
  description=descr,
  from={
    key_code: key,
    modifiers: { mandatory: ['left_command'] },
  },
);

local custom_rules = rules.rule(description=makeName('Emulate Linux copy and paste'),
                                manipulators=std.flattenArrays([
                                  [
                                    ctlToCommand(key),
                                    ctlShiftToCommand(key),
                                    unsetCommand(key),
                                  ]
                                  for key in ['v', 'c', 'x', 'z', 't', 'c', 'n', 'w', 'l', 'p', 'o', 'e', 'r', 'h']
                                ]));

local textMovement = rules.rule(
  description=makeName('Move around text'),
  manipulators=[
    rules.manipulator(
      description='Home and end key remap',
      from={ key_code: 'home' },
      to=[{
        key_code: 'left_arrow',
        modifiers: ['command'],
      }],
      // conditions=[{
      // }]
    ),
    rules.manipulator(
      description='Home and end key remap',
      from={ key_code: 'end' },
      to=[{
        key_code: 'right_arrow',
        modifiers: ['command'],
      }],
    ),
    rules.manipulator(
      description='Ctl+left_arrow remap',
      from={
        key_code: 'left_arrow',
        modifiers: {
          mandatory: ['control'],
          optional: ['shift'],
        },
      },
      to=[{
        key_code: 'left_arrow',
        modifiers: ['left_option'],
      }],
    ),
    rules.manipulator(
      description='Ctl+right_arrow remap',
      from={
        key_code: 'right_arrow',
        modifiers: {
          mandatory: ['control'],
          optional: ['shift'],
        },
      },
      to=[{
        key_code: 'right_arrow',
        modifiers: ['left_option'],
      }],
    ),
  ]
);

local aLaLinux = base.complexModification(title=makeName('Emulate Linux keybindings'),
                                          rules=[custom_rules]);


aLaLinux +
aLaLinux.withRule(textMovement)
