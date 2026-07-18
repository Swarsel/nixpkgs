{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  nix-update-script,
  nixosTests,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-randr";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-randr";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-Jimw6YCRouG9FDlLBp15OOCRlywBIaP/K/bXLR7trQM=";
  };

  nativeBuildInputs = [
    just
    pkg-config
  ];

  buildInputs = [ wayland ];
  cargoHash = "sha256-QWSPj7bxxWh5/KeNEtUsfDKg+JMONLjomrMcn57j6fw=";
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
    description = "Library and utility for displaying and configuring Wayland outputs";
    homepage = "https://github.com/pop-os/cosmic-randr";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-randr";
    teams = [ lib.teams.cosmic ];
  };
})
