# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Lily Foster <lily@lily.flowers>
# Portions of this code are adapted from nixos-cosmic
# https://github.com/lilyinstarlight/nixos-cosmic
{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  ffmpeg,
  glib,
  gst_all_1,
  just,
  libcosmicAppHook,
  libgbm,
  libglvnd,
  nix-update-script,
  nixosTests,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-player";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-player";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-4oIfTsEGMVmgS0VWLnQ1xAcPAzBeYaGT8xU3b/ObeO8=";
  };

  nativeBuildInputs = [
    just
    pkg-config
    libcosmicAppHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    ffmpeg
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    libgbm
    libglvnd
  ];

  cargoHash = "sha256-aY5QYZ1OjiCHgfFysTTU6Wp/1IexAWjuZCkTFuFY1PI=";
  env.VERGEN_GIT_SHA = finalAttrs.src.tag;

  preFixup = ''
    libcosmicAppWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")

    substituteInPlace $out/share/thumbnailers/com.system76.CosmicPlayer.thumbnailer \
      --replace-fail "TryExec=cosmic-player" "TryExec=$out/bin/cosmic-player" \
      --replace-fail "Exec=cosmic-player" "Exec=$out/bin/cosmic-player"
  '';

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
    description = "Media player for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-player";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-player";
    teams = [ lib.teams.cosmic ];
  };
})
