{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  libcosmicAppHook,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-panel";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-panel";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-DKwmZnTxsYCWAkLb9AXoHBa8m6Z5Gi1Jb7AuxZqq7RA=";
  };

  nativeBuildInputs = [
    just
    libcosmicAppHook
  ];

  cargoHash = "sha256-6E+bAi1f6gOZh64wyvLMKZiZNlMexPV+ZzS3riOx9xM=";
  __structuredAttrs = true;
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

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
    description = "Panel for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-panel";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-panel";
    teams = [ lib.teams.cosmic ];
  };
})
