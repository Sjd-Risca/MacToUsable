local apps = import 'applications.libsonnet';
local base = import 'base.libsonnet';
local rules = import 'rules.libsonnet';

local name = 'keyboardMap';
local makeName(description) = '%s-%s' % [name, description];

local keyRemapRAlt(key, to, modifiers=null, descr='Remap Keyboard') = rules.manipulator(
  description=descr,
  from={
    key_code: key,
    modifiers: { mandatory: ['right_option'] },
  },
  to={
    key_code: to,
    [if modifiers != null then 'modifiers']: modifiers,
  },
);


local custom_rules = rules.rule(
  description=makeName('Emulate Linux or Win keyboard'),
  manipulators=
  [
    keyRemapRAlt('equal_sign', '5', modifiers='option'),
    keyRemapRAlt('hyphen', 'grave_accent_and_tilde', modifiers='option'),
  ]
);

local fixPipeGreater = rules.rule(
  description=makeName('Somehow with ISO the keys pipe and greater are inverted only on macOS keyboard'),
  manipulators=[
    rules.manipulator(
      description='Remap Pipe and greater',
      from={
        key_code: 'non_us_backslash',
        modifiers: { optional: ['any'] },
      },
      to=[{ key_code: 'grave_accent_and_tilde' }],
      conditions=[{
        type: 'device_if',
        identifiers: [{ is_built_in_keyboard: true }],
      }]
    ),
    rules.manipulator(
      description='Remap Pipe and greater',
      from={
        key_code: 'grave_accent_and_tilde',
        modifiers: { optional: ['any'] },
      },
      to=[{ key_code: 'non_us_backslash' }],
      conditions=[{
        type: 'device_if',
        identifiers: [{ is_built_in_keyboard: true }],
      }]
    ),
  ]
);

local keyboardMap = base.complexModification(
  title=makeName('Keyboard remap')
);

keyboardMap +
keyboardMap.withRule(custom_rules) +
keyboardMap.withRule(fixPipeGreater)
