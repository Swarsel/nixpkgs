{
  cargoHash,
  makeBinaryWrapper,
  pname,
  rustPlatform,
  src,
  version,
}:
rustPlatform.buildRustPackage {
  inherit version src cargoHash;
  pname = "${pname}-codelldb-launch";
  nativeBuildInputs = [ makeBinaryWrapper ];
  # Tests fail to build (as of version 1.12.0).
  doCheck = false;

  cargoBuildFlags = [
    "--package=codelldb-launch"
  ];
}
