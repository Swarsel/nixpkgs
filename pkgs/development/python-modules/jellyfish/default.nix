{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  pytestCheckHook,
  rustPlatform,
  rustc,
  unicodecsv,
}:

buildPythonPackage rec {
  pname = "jellyfish";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "jamesturk";
    repo = "jellyfish";
    rev = "v${version}";
    hash = "sha256-jKz7FYzV66TUkJZfWDTy8GXmTZ6SU5jEdtkjYLDfS/8=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeCheckInputs = [
    pytestCheckHook
    unicodecsv
  ];

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  pyproject = true;
  pythonImportsCheck = [ "jellyfish" ];

  meta = {
    description = "Python library for doing approximate and phonetic matching of strings";
    homepage = "https://github.com/jamesturk/jellyfish";
    changelog = "https://github.com/jamesturk/jellyfish/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ koral ];
  };
}
