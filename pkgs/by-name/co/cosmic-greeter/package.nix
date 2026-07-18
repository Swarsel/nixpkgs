{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  coreutils,
  cosmic-randr,
  just,
  libcosmicAppHook,
  libinput,
  linux-pam,
  nix-update-script,
  nixosTests,
  orca,
  rustPlatform,
  udev,
  xkeyboard_config,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-greeter";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-greeter";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-JaPF2kFXQLumPBn8JFBiaSJ/tP3QqK/hwhy5rZrLuY4=";
  };

  postPatch = ''
    substituteInPlace src/greeter.rs --replace-fail '/usr/bin/env' '${lib.getExe' coreutils "env"}'
    substituteInPlace src/greeter.rs --replace-fail '/usr/bin/orca' '${lib.getExe orca}'
  '';

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    cmake
    just
    libcosmicAppHook
  ];

  buildInputs = [
    cosmic-randr
    libinput
    linux-pam
    udev
    orca
  ];

  cargoHash = "sha256-mfY2hsMxBooRjmTB2jgUIKyKHBpGfZ9Qslwv+2aEQyg=";
  env.VERGEN_GIT_SHA = finalAttrs.src.tag;

  preFixup = ''
    libcosmicAppWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ cosmic-randr ]}
      --set-default X11_BASE_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/base.xml
      --set-default X11_BASE_EXTRA_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/extra.xml
    )
  '';

  __structuredAttrs = true;
  cargoBuildFlags = [ "--all" ];
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
    description = "Greeter for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-greeter";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-greeter";
    teams = [ lib.teams.cosmic ];
  };
})
