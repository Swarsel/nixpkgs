{
  lib,
  stdenv,
  dbus-glib,
  fetchzip,
  glib,
  gnome-common,
  gsettings-desktop-schemas,
  libnotify,
  libtool,
  libwnck,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "notify-osd";
  version = "0.9.35+20.04.20191129";

  src = fetchzip {
    url = "https://launchpad.net/ubuntu/+archive/primary/+files/notify-osd_${finalAttrs.version}.orig.tar.gz";
    sha256 = "sha256-aSU83HoWhHZtob8NFHFYNUIIZAecvQ/p0z62KMlQNCU=";
    stripRoot = false;
  };

  # deprecated function: g_memdup
  postPatch = ''
    substituteInPlace src/stack.c \
      --replace-fail "g_memdup" "g_memdup2"
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    libtool
  ];

  buildInputs = [
    glib
    libwnck
    libnotify
    dbus-glib
    gsettings-desktop-schemas
    gnome-common
  ];

  configureFlags = [
    "--libexecdir=$(out)/bin"
  ];

  env = {
    NIX_CFLAGS_COMPILE = "-fpermissive";
  };

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  preFixup = ''
    wrapProgram "$out/bin/notify-osd" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
  '';

  meta = {
    description = "Daemon that displays passive pop-up notifications";
    homepage = "https://launchpad.net/notify-osd";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ bodil ];
    platforms = lib.platforms.linux;
    mainProgram = "notify-osd";
  };
})
