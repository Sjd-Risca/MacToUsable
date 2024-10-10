// Common applications
local condTypes = {
  identifier: 'bundle_identifiers',
  path: 'file_paths',
};

local appSelector(identifier=null, path=null) = {
  assert std.length(std.prune([identifier, path])) == 1 : 'set only an identifier or a path regex',
  type: if identifier == null then condTypes.path else condTypes.identifier,
  regex: if identifier == null then path else identifier,
};

local condition(appList, type='is') =
  {
    _bundles:: std.prune([if app.type == condTypes.identifier then
      app.regex for app in appList]),
    bundle_identifiers: $._bundles,
    _paths:: std.prune([if app.type == condTypes.path then
      app.regex for app in appList]),
    file_paths: $._paths,
    type: if type == 'is' then
      'frontmost_application_if' else
      'frontmost_application_unless',
  };

{
  apps: {
    terminal: appSelector('^com\\.apple\\.Terminal$'),
    alacritty: appSelector('^org\\.alacritty$'),
    kitty: appSelector('^net\\.kovidgoyal\\.kitty$'),
  },
  type: {
    local app = $.apps,
    terminal: [app.terminal, app.alacritty, app.kitty],
  },
  conditions: {
    local type = $.type,
    is: {
      terminal: [condition(type.terminal)],
    },
    isNot: {
      terminal: [condition(type.terminal, type='isNot')],
    },
  },
}
