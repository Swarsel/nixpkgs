{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus-glib,
  glib,
  gtk3,
  intltool,
  libx11,
  libxext,
  libxscrnsaver,
  libxxf86vm,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  systemd,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "light-locker";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "the-cavalry";
    repo = "light-locker";
    rev = "v${version}";
    sha256 = "1z5lcd02gqax65qc14hj5khifg7gr53zy3s5i6apba50lbdlfk46";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    intltool
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus-glib
    glib
    gtk3
    libx11
    libxscrnsaver
    libxext
    libxxf86vm
    systemd
  ];

  mesonFlags = [
    "-Dmit-ext=true"
    "-Ddpms-ext=true"
    "-Dxf86gamma-ext=true"
    "-Dsystemd=true"
    "-Dupower=true"
    "-Dlate-locking=true"
    "-Dlock-on-suspend=true"
    "-Dlock-on-lid=true"
    "-Dgsettings=true"
  ];

  postInstall = ''
    ${glib.dev}/bin/glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple session-locker for LightDM";

    longDescription = ''
      A simple locker (forked from gnome-screensaver) that aims to
      have simple, sane, secure defaults and be well integrated with
      the desktop while not carrying any desktop-specific
      dependencies.

      It relies on LightDM for locking and unlocking your session via
      ConsoleKit/UPower or logind/systemd.
    '';

    homepage = "https://github.com/the-cavalry/light-locker";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ obadz ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
