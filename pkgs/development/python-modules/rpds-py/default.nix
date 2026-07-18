{
  lib,
  stdenv,
  buildPythonPackage,
  cargo,
  fetchPypi,
  libiconv,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "rpds-py";
  version = "0.30.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3Y/3z5ABSvDA94fuo0eU6/ZBUkLuHW+pHqunJcxEHoQ=";
    pname = "rpds_py";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    cargo
    rustc
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  nativeCheckInputs = [ pytestCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-2m2DW1rknZR+UztgUcRaQk4gY19eXmT089U2YlV16d8=";
  };

  pyproject = true;
  pythonImportsCheck = [ "rpds" ];

  meta = {
    description = "Python bindings to Rust's persistent data structures";
    homepage = "https://github.com/crate-py/rpds";
    changelog = "https://github.com/crate-py/rpds/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
