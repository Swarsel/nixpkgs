{
  base,
  linear,
  mkPrelude,
  prelude,
}:
mkPrelude {
  dependencies = [
    prelude
    base
    linear
  ];

  name = "network";
}
