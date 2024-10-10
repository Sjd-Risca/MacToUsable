//Utility for base setup

local complexModification(title='Demo', rules=[]) = {
  title: title,
  rules: rules,
  withRule(rule):: { rules+: [rule] },
};

{ complexModification: complexModification }
