{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  jsonalias,
  openssl,
  pkg-config,
  pkgs,
  rustPlatform,
  rustc,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "solders";
  version = "0.27.1";

  src = fetchFromGitHub {
    owner = "kevinheavey";
    repo = "solders";
    tag = "v${finalAttrs.version}";
    hash = "sha256-a3G3mMJvnO24w6WEJnEkYUNinXWHR26KupIlq5eik8A=";
  };

  buildInputs = [
    openssl
    pkgs.zstd
  ];

  env = {
    OPENSSL_NO_VENDOR = true;

    PKG_CONFIG_PATH = lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
      openssl
      pkgs.zstd
    ];

    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  build-system = [
    cargo
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-+8iaA1Cs+7qiDfQpwPAWSZ1HuF85WaDZB3MN57QOodI=";
  };

  dependencies = [
    jsonalias
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "solders" ];
  pythonRelaxDeps = [ "jsonalias" ];

  meta = {
    description = "Python toolkit for Solana";
    homepage = "https://github.com/kevinheavey/solders";
    changelog = "https://github.com/kevinheavey/solders/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
