{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  frelatage,
  libiconv,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "base2048";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "ionite34";
    repo = "base2048";
    tag = "v${version}";
    hash = "sha256-OXlfycJB1IrW2Zq0xPDGjjwCdRTWtX/ixPGWcd+YjAg=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  nativeCheckInputs = [ pytestCheckHook ];
  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };

  optional-dependencies = {
    fuzz = [ frelatage ];
  };

  pyproject = true;
  pythonImportsCheck = [ "base2048" ];

  meta = {
    description = "Binary encoding with base-2048 in Python with Rust";
    homepage = "https://github.com/ionite34/base2048";
    changelog = "https://github.com/ionite34/base2048/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
