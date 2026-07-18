{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  python,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
}:

buildPythonPackage rec {
  pname = "fastbencode";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "breezy-team";
    repo = "fastbencode";
    tag = "v${version}";
    hash = "sha256-e+Ei+UIJ5sve6k3ApPJ2nswTgZLkzxZmpthK/f/rfCs=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m unittest tests.test_suite
    runHook postCheck
  '';

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-dqD/QF6/XCB9H/QkEobfIOo9S663fh9AHUuHqCoEcLM=";
  };

  pyproject = true;
  pythonImportsCheck = [ "fastbencode" ];

  meta = {
    description = "Fast implementation of bencode";
    homepage = "https://github.com/breezy-team/fastbencode";
    changelog = "https://github.com/breezy-team/fastbencode/releases/tag/v${version}";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
}
