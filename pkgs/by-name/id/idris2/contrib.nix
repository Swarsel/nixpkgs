{
  base,
  mkPrelude,
  prelude,
}:
mkPrelude {
  dependencies = [
    prelude
    base
  ];

  name = "contrib";
}
