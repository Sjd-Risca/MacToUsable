// Generate main karabiner setup directly (most user probably will only want a subset of rules)
local copyAndPaste = import 'sources/copyAndPaste.libsonnet';
local keyboardMap = import 'sources/keyboardMap.libsonnet';
local yabai = import 'sources/yabai.libsonnet';

{
  profiles: [
    {
      complex_modifications: {
        rules: [
        ] + yabai.rules + keyboardMap.rules + copyAndPaste.rules,
      },
      devices: [
        {
          identifiers: { is_keyboard: true },
          simple_modifications: [
            {
              from: { apple_vendor_top_case_key_code: 'keyboard_fn' },
              to: [{ key_code: 'left_control' }],
            },
            {
              from: { key_code: 'left_command' },
              to: [{ key_code: 'left_option' }],
            },
            {
              from: { key_code: 'left_control' },
              to: [{ apple_vendor_top_case_key_code: 'keyboard_fn' }],
            },
            {
              from: { key_code: 'left_option' },
              to: [{ key_code: 'left_command' }],
            },
            {
              from: { key_code: 'right_command' },
              to: [{ key_code: 'right_option' }],
            },

          ],
        },
      ],
      name: 'yabai',
      selected: true,
      virtual_hid_keyboard: { keyboard_type_v2: 'iso' },
    },
  ],
}
