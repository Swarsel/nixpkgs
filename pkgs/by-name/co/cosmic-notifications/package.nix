{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  libcosmicAppHook,
  nix-update-script,
  nixosTests,
  rustPlatform,
  which,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-notifications";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-notifications";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-84e+idGKYDBerS84Cl9jPc/Z9RzuVvND7nHzmApsrgA=";
  };

  nativeBuildInputs = [
    just
    which
    libcosmicAppHook
  ];

  cargoHash = "sha256-EIwYabYWSHTMnNFcammidn3bI4fc6JFdcVkGj7RmWqA=";
  __structuredAttrs = true;
  dontUseJustBuild = true;
  # Runs the default checkPhase instead
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
    description = "Notifications for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-notifications";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-notifications";
    teams = [ lib.teams.cosmic ];
  };
})
