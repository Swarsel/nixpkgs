{
  lib,
  stdenv,
  fetchFromGitHub,
  libcosmicAppHook,
  libgbm,
  libinput,
  nix-update-script,
  nixosTests,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-workspaces-epoch";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-workspaces-epoch";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-riiveHFtRF3rtOhbbUtfYRoAlqc7TCRr8aer0dgBY7g=";
  };

  nativeBuildInputs = [
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [
    libinput
    libgbm
    udev
  ];

  cargoHash = "sha256-Z5dC3W8QoDBZWBjHwRj9MC8EScDjQwUiUcOPTRDToDA=";

  makeFlags = [
    "prefix=${placeholder "out"}"
    "CARGO_TARGET_DIR=target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  __structuredAttrs = true;
  dontCargoInstall = true;
  separateDebugInfo = true;

  passthru = {
    tests = {
      inherit (nixosTests)
        cosmic
        cosmic-autologin
        cosmic-noxwayland
        cosmic-autologin-noxwayland
        ;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "epoch-(.*)"
      ];
    };
  };

  meta = {
    description = "Workspaces Epoch for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-workspaces-epoch";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-workspaces";
    teams = [ lib.teams.cosmic ];
  };
})
