{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  glib,
  just,
  libcosmicAppHook,
  libinput,
  nix-update-script,
  nixosTests,
  pipewire,
  pkg-config,
  pulseaudio,
  rustPlatform,
  udev,
  util-linuxMinimal,
  xkeyboard_config,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-applets";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-applets";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-tygAgaafoU0CnTzKPb00uVaYTieCJ4uNjux3AYyYtXQ=";
  };

  nativeBuildInputs = [
    just
    pkg-config
    util-linuxMinimal
    libcosmicAppHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    dbus
    glib
    libinput
    pulseaudio
    pipewire
    udev
  ];

  cargoHash = "sha256-81BFu13QmqOq43iN+ORQuktisEFYRrK+wd6diFfSufs=";

  preFixup = ''
    libcosmicAppWrapperArgs+=(
      --set-default X11_BASE_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/base.xml
      --set-default X11_EXTRA_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/base.extras.xml
    )
  '';

  __structuredAttrs = true;

  cargoPatches = [
    # A different reference to the `cosmic-settings-daemon` crate was added
    # Remove this patch once upstream fixes their lockfile.
    ./dedup-cosmic-settings-daemon.patch
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "target"
    "${stdenv.hostPlatform.rust.cargoShortTarget}/release"
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
    description = "Applets for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-applets";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cosmic ];
  };
})
