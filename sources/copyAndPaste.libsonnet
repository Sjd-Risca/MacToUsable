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

base.complexModification(title=makeName('Copy and paste linux way'),
                         rules=[custom_rules])
