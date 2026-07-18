{
  cargoDeps,
  rustPlatform,
  src,
  version,
}:

rustPlatform.buildRustPackage {
  inherit
    version
    src
    cargoDeps
    ;

  pname = "lix-doc";
  sourceRoot = "${src.name or src}/lix-doc";
}
