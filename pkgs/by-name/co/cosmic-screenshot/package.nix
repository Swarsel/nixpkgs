{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  nix-update-script,
  nixosTests,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-screenshot";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-screenshot";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-RYvc/3FoRnNkuYBVfCG75Bmfb8JWW1H4GKXyhq7CxaQ=";
  };

  nativeBuildInputs = [
    just
    pkg-config
  ];

  cargoHash = "sha256-q0RJST1yeqPBjU5MseNZIrZw+brfDtQLKiw7wyViflE=";
  __structuredAttrs = true;
  dontUseJustBuild = true;

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
    description = "Screenshot tool for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-screenshot";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-screenshot";
    teams = [ lib.teams.cosmic ];
  };
})
