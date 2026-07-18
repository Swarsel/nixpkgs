{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libiconv,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "py-bip39-bindings";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "polkascan";
    repo = "py-bip39-bindings";
    tag = "v${version}";
    hash = "sha256-jpBlupIjlH2LJkSm3tzxrH5wT2+eziugNMR4B01gSdE=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  nativeCheckInputs = [ pytestCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-qX4ydIT2+8dJQIVSYzO8Rg8PP61cu7ZjanPkmI34IUY=";
  };

  enabledTestPaths = [ "tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "bip39" ];

  meta = {
    description = "Python bindings for the tiny-bip39 library";
    homepage = "https://github.com/polkascan/py-bip39-bindings";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stargate01 ];
  };
}
