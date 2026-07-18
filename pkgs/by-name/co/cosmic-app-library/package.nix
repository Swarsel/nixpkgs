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
  pname = "cosmic-app-library";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-app-library";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-TZncRQer4lXunUwdQ2xDP3DmF5B7UmfhSQvEwVodc98=";
  };

  nativeBuildInputs = [
    just
    libcosmicAppHook
  ];

  cargoHash = "sha256-qGx/3w78mgIMqRo1wJA+ULFHWdNW2LKe2Sej4f9KbVs=";
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
    description = "Application Template for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-app-library";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-app-library";
    teams = [ lib.teams.cosmic ];
  };
})
