{
  lib,
  stdenv,
  fetchFromGitHub,
  libcosmicAppHook,
  libdisplay-info_0_2,
  libgbm,
  libinput,
  nix-update-script,
  nixosTests,
  pixman,
  pkg-config,
  rustPlatform,
  seatd,
  systemd,
  udev,
  useSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-comp";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-comp";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-yhgjdkAzUipGAo7Jv9hWlhOb/dLXn1/68yX+tRO6UV4=";
  };

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
  ];

  buildInputs = [
    libdisplay-info_0_2
    libgbm
    libinput
    pixman
    seatd
    udev
  ]
  ++ lib.optional useSystemd systemd;

  cargoHash = "sha256-Yi1nVvWmFzlXxHN01BeeGc9YRqrRoVXTqehisOrGWS0=";

  makeFlags = [
    "prefix=${placeholder "out"}"
    "CARGO_TARGET_DIR=target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  __structuredAttrs = true;
  # Only default feature is systemd
  buildNoDefaultFeatures = !useSystemd;
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
    description = "Compositor for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-comp";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-comp";
    teams = [ lib.teams.cosmic ];
  };
})
