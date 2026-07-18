{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  dbus,
  libgcc,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fum";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "qxb3";
    repo = "fum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qZGbJGotxJCxlMIRPS/hw/cfz/k8PFdVKoJtqWKXD6s=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    pkg-config
  ];

  buildInputs = [
    openssl
    dbus
    libgcc
  ];

  cargoHash = "sha256-g6Nn3teRHMdlKReX3j0jkhfJEHOigDF4ghSfSYU33o8=";
  doCheck = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fully ricable tui-based music client";
    homepage = "https://github.com/qxb3/fum";
    changelog = "https://github.com/qxb3/fum/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ FKouhai ];
    platforms = lib.platforms.linux;
    mainProgram = "fum";
  };
})
