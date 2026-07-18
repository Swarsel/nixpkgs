{
  buildPythonPackage,
  bzip2,
  ironcalc,
  pkg-config,
  pytestCheckHook,
  python3,
  rustPlatform,
  zstd,
}:

buildPythonPackage {
  inherit (ironcalc) src version;
  pname = "ironcalc";

  postPatch = ''
    cd bindings/python
  '';

  strictDeps = true;

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    pkg-config
  ];

  buildInputs = [
    bzip2
    zstd
  ];

  env.PYO3_PYTHON = "${python3}/bin/python3";
  doCheck = true;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (ironcalc) src;
    hash = ironcalc.cargoHash;
  };

  cargoRoot = "../..";
  pyproject = true;
  pythonImportsCheck = [ "ironcalc" ];

  meta = ironcalc.meta // {
    description = "Python bindings for IronCalc";
  };
}
