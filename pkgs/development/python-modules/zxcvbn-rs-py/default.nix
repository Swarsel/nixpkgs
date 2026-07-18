{
  lib,
  buildPythonPackage,
  fetchPypi,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "zxcvbn-rs-py";
  version = "0.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0nQmgII6F0gj8HCnNAdLvowWBPExPAgXCxWAJuNsc6A=";
    pname = "zxcvbn_rs_py";
  };

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-S6K6ZzW24V2yFV89B+gN+Odc4h3R45lF+emZs69dzYg=";
  };

  pyproject = true;
  pythonImportsCheck = [ "zxcvbn_rs_py" ];

  meta = {
    description = "Python bindings for zxcvbn-rs, the Rust implementation of zxcvbn";
    homepage = "https://github.com/fief-dev/zxcvbn-rs-py/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };

}
