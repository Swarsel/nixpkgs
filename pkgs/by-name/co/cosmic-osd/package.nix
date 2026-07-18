{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  libcosmicAppHook,
  libinput,
  nix-update-script,
  nixosTests,
  pipewire,
  pulseaudio,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-osd";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-osd";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-veqkYF2CSwnc1nGIFeZXpfannCQ0RuacvqPVxVsiVDc=";
  };

  nativeBuildInputs = [
    just
    libcosmicAppHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pulseaudio
    udev
    libinput
    pipewire
  ];

  cargoHash = "sha256-aweq4E2bwqRpetakpR0OqTsIsoJK6h4eRzMdBhGuIoU=";
  env.POLKIT_AGENT_HELPER_1 = "/run/wrappers/bin/polkit-agent-helper-1";
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
    description = "OSD for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-osd";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-osd";
    teams = [ lib.teams.cosmic ];
  };
})
