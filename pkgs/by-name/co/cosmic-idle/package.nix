# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Lily Foster <lily@lily.flowers>
# Portions of this code are adapted from nixos-cosmic
# https://github.com/lilyinstarlight/nixos-cosmic
{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  just,
  libcosmicAppHook,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-idle";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-idle";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-0tcrOfVT5b57ev3b5F2U78F2QPGFwp94bqFVNyKH0Yk=";
  };

  postPatch = ''
    substituteInPlace src/main.rs --replace-fail '"/bin/sh"' '"${lib.getExe' bash "sh"}"'
  '';

  nativeBuildInputs = [
    just
    libcosmicAppHook
  ];

  cargoHash = "sha256-wAjFC6qAC3nllbnZf0KVaZTEztNYo6GTvwcp5FYmXLw=";
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
    description = "Idle daemon for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-idle";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-idle";
    teams = [ lib.teams.cosmic ];
  };
})
