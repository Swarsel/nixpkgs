{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  elementary-default-settings,
  gettext,
  gnome-keyring,
  gnome-session,
  gnome-settings-daemon,
  meson,
  ninja,
  nix-update-script,
  onboard,
  orca,
  pkg-config,
  runtimeShell,
  systemd,
  wingpanel,
  writeText,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elementary-session-settings";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "session-settings";
    tag = finalAttrs.version;
    hash = "sha256-mdfmCzR9ikXDlDc7FeOITsdbPbz+G66jUrl1BobY+g8=";
  };

  patches = [
    # See https://github.com/elementary/session-settings/issues/88 for gnome-keyring.
    # See https://github.com/elementary/session-settings/issues/82 for onboard.
    ./no-autostart.patch
  ];

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gnome-keyring
    gnome-settings-daemon
    onboard
    orca
    systemd
  ];

  mesonFlags = [
    "-Dmimeapps-list=false"
    "-Ddetect-program-prefixes=true"
    # https://github.com/elementary/session-settings/issues/91
    "-Dx11=false"
    "--sysconfdir=${placeholder "out"}/etc"
  ];

  postInstall = ''
    # our mimeapps patched from upstream to exclude:
    # * evince.desktop -> org.gnome.Evince.desktop
    mkdir -p $out/share/applications
    cp -av ${./pantheon-mimeapps.list} $out/share/applications/pantheon-mimeapps.list

    # absolute path patched sessions
    substituteInPlace $out/share/wayland-sessions/pantheon-wayland.desktop \
      --replace-fail "Exec=gnome-session" "Exec=${gnome-session}/bin/gnome-session" \
      --replace-fail "TryExec=io.elementary.wingpanel" "TryExec=${wingpanel}/bin/io.elementary.wingpanel"
  '';

  passthru = {
    providedSessions = [
      "pantheon-wayland"
    ];

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Session settings for elementary";
    homepage = "https://github.com/elementary/session-settings";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
})
