{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "drill";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "fcsonline";
    repo = "drill";
    rev = finalAttrs.version;
    sha256 = "sha256-jBnRVTnrSfEpN7xgMrlAsCwl62kZpHMI4IeT0rPb+zg=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    openssl
  ];

  cargoHash = "sha256-CfPmTmtCpBgxDH043yIedZk9dngPb5L6z7jQpmvtiEA=";

  env = {
    OPENSSL_DIR = "${lib.getDev openssl}";
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  };

  meta = {
    description = "HTTP load testing application inspired by Ansible syntax";
    homepage = "https://github.com/fcsonline/drill";
    license = lib.licenses.gpl3Only;
    mainProgram = "drill";
  };
})
