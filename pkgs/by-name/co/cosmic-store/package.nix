{
  lib,
  stdenv,
  fetchFromGitHub,
  flatpak,
  glib,
  just,
  libcosmicAppHook,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-store";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-store";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-DqkYwbEph6GJM9Gok/XaiIFyWnv0+W+geviyzrXmQ8I=";
  };

  nativeBuildInputs = [
    just
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [
    glib
    flatpak
    openssl
  ];

  cargoHash = "sha256-IuMCYUZWtzvGyLMNb+Kwoj6M9fKaEYFMfcfYYVggVYw=";
  env.VERGEN_GIT_SHA = finalAttrs.src.tag;
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
    description = "App Store for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-store";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cosmic ];
  };
})
