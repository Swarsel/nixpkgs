{ mkPrelude, prelude }:
mkPrelude {
  dependencies = [ prelude ];
  name = "base";
}
