{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  callPackage,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  tzdata,
  versionCheckHook,
  librusty_v8 ? (
    callPackage ./librusty_v8.nix {
      inherit (callPackage ./fetchers.nix { }) fetchLibrustyV8;
    }
  ),
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brioche";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "brioche-dev";
    repo = "brioche";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j0Hi75olubvlHEOzVbW0cMAslZFWCzHiwXaBqmkXzmE=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-3UvggE45Gvus5ghd64ZK+Nh/VB3NJBmZNrbStl/xJu0=";

  env = {
    OPENSSL_NO_VENDOR = true;
    RUSTY_V8_ARCHIVE = librusty_v8;
  };

  # Tests require network access and CA certificates, which are unavailable in the nix sandbox
  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgramArg = "--version";

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script { })
    ./update-librusty.sh
  ];

  meta = {
    description = "Package manager for building and running complex software projects";
    homepage = "https://brioche.dev/";
    changelog = "https://github.com/brioche-dev/brioche/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "brioche";
    downloadPage = "https://github.com/brioche-dev/brioche";
  };
})
