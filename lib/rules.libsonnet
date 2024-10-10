// Basic rule
local manipulator(description=null,
                  from=null,
                  to=null,
                  conditions=null,
                  parameters=null) = {
  assert std.isObject(from) : 'from is required in any rule',
  [if description != null then 'description']: description,
  type: 'basic',
  from: from,
  [if to != null then 'to']: to,
  [if conditions != null then 'conditions']: conditions,
  [if parameters != null then 'parameters']: parameters,
};

local isManipulator(o) = std.all([std.objectHas(o, 'from'), std.get('type') == 'basic']);

local rule(description='New rule', manipulators=[]) = {
  assert std.isArray(manipulators) : 'manipulators has to be an array of manipulators',
  description: description,
  manipulators: manipulators,
  withManipulators(manipulator):: self + { manipulators+: [manipulator] },
};

{
  rule: rule,
  manipulator: manipulator,
  isManipulator: isManipulator,
}
