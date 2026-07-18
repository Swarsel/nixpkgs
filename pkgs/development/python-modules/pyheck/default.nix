{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  libiconv,
  poetry-core,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "pyheck";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "kevinheavey";
    repo = "pyheck";
    tag = version;
    hash = "sha256-mfXkrCbBaJ0da+taKJvfyU5NS43tYJWqtTUXiCLVoGQ=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    cargo
    poetry-core
    rustc
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  nativeCheckInputs = [ pytestCheckHook ];
  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };
  pyproject = true;
  pythonImportsCheck = [ "pyheck" ];

  meta = {
    description = "Python bindings for heck, the Rust case conversion library";
    homepage = "https://github.com/kevinheavey/pyheck";
    changelog = "https://github.com/kevinheavey/pyheck/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
