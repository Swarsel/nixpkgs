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
  pname = "cosmic-launcher";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-launcher";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-Dy1sOEe/Cb1wyXHETZ5wJt8IcJMGw19OeDGOhuv4kQg=";
  };

  nativeBuildInputs = [
    just
    libcosmicAppHook
  ];

  cargoHash = "sha256-WnZAPQR8hGGNC5S7hPmcGSMs9HrOw4/wqJR151eIgHY=";
  env."CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_RUSTFLAGS" = "--cfg tokio_unstable";
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
    description = "Launcher for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-launcher";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-launcher";
    teams = [ lib.teams.cosmic ];
  };
})
