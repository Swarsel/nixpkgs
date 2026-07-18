{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
}:

buildPythonPackage rec {
  pname = "cryptg";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "cher-nov";
    repo = "cryptg";
    rev = "v${version}";
    hash = "sha256-3vdZGtr4NTtba42jqklhEEMWqHgEct/0Rw0Krllgcn4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "setuptools[core]" "setuptools"
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustc
    cargo
  ];

  # has no tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-dnSxRHpjUIXgWScZS18ImxMOfhyq1iC2QPFs1h4l1AQ=";
  };

  pyproject = true;
  pythonImportsCheck = [ "cryptg" ];

  meta = {
    description = "Official Telethon extension to provide much faster cryptography for Telegram API requests";
    homepage = "https://github.com/cher-nov/cryptg";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
