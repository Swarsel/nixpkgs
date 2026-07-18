{
  lib,
  stdenv,
  fetchFromGitHub,
  cosmic-wallpapers,
  glib,
  gst_all_1,
  just,
  libcosmicAppHook,
  libgbm,
  nix-update-script,
  nixosTests,
  pipewire,
  pkg-config,
  rustPlatform,
  util-linux,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xdg-desktop-portal-cosmic";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "xdg-desktop-portal-cosmic";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-/2pn+snrXnPTPbcwg+pg/zcn9WxE3/3xXpNFlN/RITM=";
  };

  postPatch = ''
    substituteInPlace src/screenshot.rs src/widget/screenshot.rs \
      --replace-fail '/usr/share/backgrounds' '${cosmic-wallpapers}/share/backgrounds'
  '';

  nativeBuildInputs = [
    just
    libcosmicAppHook
    rustPlatform.bindgenHook
    pkg-config
    util-linux
  ];

  buildInputs = [
    glib
    libgbm
    pipewire
  ];

  cargoHash = "sha256-wSwXzaU872KqcRgAIKRuQFvG9f/q4z0OysysLyYMwdg=";
  checkInputs = [ gst_all_1.gstreamer ];
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
    description = "XDG Desktop Portal for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/xdg-desktop-portal-cosmic";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "xdg-desktop-portal-cosmic";
    teams = [ lib.teams.cosmic ];
  };
})
