{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "taskchampion-sync-server";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "GothenburgBitFactory";
    repo = "taskchampion-sync-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ywBmVid70ZKUkTwxORrwXPV0zur0RdHToTLTx9ynjqU=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    openssl
  ];

  cargoHash = "sha256-1bqZAFKQGTCGUs7EXLwAgUxQU+KmhVGFIATIOb5uOlA=";

  env = {
    # Use system openssl.
    OPENSSL_DIR = lib.getDev openssl;
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_NO_VENDOR = 1;
  };

  meta = {
    description = "Sync server for Taskwarrior 3";
    homepage = "https://github.com/GothenburgBitFactory/taskchampion-sync-server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mlaradji ];
    mainProgram = "taskchampion-sync-server";
  };
})
