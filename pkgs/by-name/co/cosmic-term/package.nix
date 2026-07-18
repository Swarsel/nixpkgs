{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  just,
  libcosmicAppHook,
  libinput,
  nix-update-script,
  nixosTests,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-term";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-term";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-0LGbe9oOwkNKU3XboEeZfi3isRbX95rIu+/VWWf6N68=";
  };

  nativeBuildInputs = [
    just
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [
    fontconfig
    freetype
    libinput
  ];

  cargoHash = "sha256-JJQ+CLSaqdqTWcbb/Oj6a1vjIHXIYQsmMn+PtmHt0Gc=";
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
    description = "Terminal for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-term";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-term";
    teams = [ lib.teams.cosmic ];
  };
})
