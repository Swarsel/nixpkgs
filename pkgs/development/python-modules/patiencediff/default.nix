{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  pytestCheckHook,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
}:

buildPythonPackage rec {
  pname = "patiencediff";
  version = "0.2.19";

  src = fetchFromGitHub {
    owner = "breezy-team";
    repo = "patiencediff";
    tag = "v${version}";
    hash = "sha256-xynrYf5oCIPk22jqjvXNYTyaXzVaUjRpn35vbx+t8vU=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
  ];

  # make rust bindings non-optional
  env.CIBUILDWHEEL = "1";
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-JW2Oj1oxAVf9K3lyJQpbHqw9eeNYDg3Agb189bduqlI=";
  };

  pyproject = true;
  pythonImportsCheck = [ "patiencediff" ];

  meta = {
    description = "C implementation of patiencediff algorithm for Python";
    homepage = "https://github.com/breezy-team/patiencediff";
    changelog = "https://github.com/breezy-team/patiencediff/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ wildsebastian ];
    mainProgram = "patiencediff";
  };
}
