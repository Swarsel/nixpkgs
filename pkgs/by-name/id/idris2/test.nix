{
  base,
  contrib,
  mkPrelude,
  prelude,
}:
mkPrelude {
  dependencies = [
    prelude
    base
    contrib
  ];

  name = "test";
}
