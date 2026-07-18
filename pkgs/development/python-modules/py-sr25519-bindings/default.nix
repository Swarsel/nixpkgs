{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libiconv,
  py-bip39-bindings,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "py-sr25519-bindings";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "JAMdotTech";
    repo = "py-sr25519";
    tag = "v${version}";
    hash = "sha256-kCOmmzCCR363J5pYJ99BDUhUWeYniMf+e+NJByRnl+c=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  nativeCheckInputs = [
    pytestCheckHook
    py-bip39-bindings
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-3snEx0rpMBRnuWt5WfTWrQkTC9fTsHh6zS4ChaRjVKg=";
  };

  enabledTestPaths = [ "tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "sr25519" ];

  meta = {
    description = "Python bindings for sr25519 library";
    homepage = "https://github.com/JAMdotTech/py-sr25519";
    changelog = "https://github.com/JAMdotTech/py-sr25519/releases/tag/${src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      onny
      stargate01
    ];
  };
}
