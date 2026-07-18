{
  lib,
  stdenv,
  fetchFromGitHub,
  cinnamon-desktop,
  cinnamon-translations,
  colord,
  cups,
  fontconfig,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  lcms2,
  libcanberra-gtk3,
  libgudev,
  libnotify,
  librsvg,
  libwacom,
  libx11,
  libxext,
  libxi,
  meson,
  ninja,
  nss,
  pkg-config,
  polkit,
  systemd,
  tzdata,
  upower,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cinnamon-settings-daemon";
  version = "6.6.4";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "cinnamon-settings-daemon";
    tag = finalAttrs.version;
    hash = "sha256-zdrT9te/C62g1MZlILbicxaDWO+uS3iW448YBTpPz1Y=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./csd-backlight-helper-fix.patch
  ];

  postPatch = ''
    sed "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|g" -i plugins/datetime/system-timezone.h
  '';

  nativeBuildInputs = [
    meson
    ninja
    wrapGAppsHook3
    pkg-config
  ];

  buildInputs = [
    cinnamon-desktop
    colord
    gtk3
    glib
    gsettings-desktop-schemas
    lcms2
    libcanberra-gtk3
    libnotify
    systemd
    upower
    cups
    polkit
    librsvg
    libwacom
    libxext
    libx11
    libxi
    fontconfig
    nss
    libgudev
  ];

  # use locales from cinnamon-translations (not using --localedir because datadir is used)
  postInstall = ''
    ln -s ${cinnamon-translations}/share/locale $out/share/locale
  '';

  # So the polkit policy can reference /run/current-system/sw/bin/cinnamon-settings-daemon/csd-backlight-helper
  postFixup = ''
    mkdir -p $out/bin/cinnamon-settings-daemon
    ln -s $out/libexec/csd-backlight-helper $out/bin/cinnamon-settings-daemon/csd-backlight-helper
  '';

  meta = {
    description = "Settings daemon for the Cinnamon desktop";
    homepage = "https://github.com/linuxmint/cinnamon-settings-daemon";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
