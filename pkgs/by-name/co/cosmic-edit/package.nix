{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  glib,
  just,
  libcosmicAppHook,
  libinput,
  nix-update-script,
  nixosTests,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-edit";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-edit";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-w6Os3R//40ED9q6wyiABmIgofdj+WaLZPD/4+1EF7aY=";
  };

  postPatch = ''
    substituteInPlace justfile --replace-fail '#!/usr/bin/env' "#!$(command -v env)"
  '';

  nativeBuildInputs = [
    just
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [
    glib
    libinput
    fontconfig
    freetype
  ];

  cargoHash = "sha256-/OnmUO7WFXvZPq+0nPe2BKbYZRR0Ku+V8+qeLWnYHPQ=";
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
    description = "Text Editor for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-edit";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-edit";
    teams = [ lib.teams.cosmic ];
  };
})
