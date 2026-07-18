{
  lib,
  stdenv,
  fetchFromGitLab,
  at-spi2-core,
  autoreconfHook,
  dbus,
  expat,
  glib,
  gnome-doc-utils,
  gtk3,
  itstool,
  libxml2,
  libxslt,
  pkg-config,
  speechd-minimal,
  which,
  wrapGAppsHook3,
  speechSupport ? true,
}:

stdenv.mkDerivation {
  pname = "dasher";
  version = "unstable-2021-04-25";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "dasher";
    rev = "90c753b87564fa3f42cb2d04e1eb6662dc8e0f8f";
    sha256 = "sha256-aM05CV68pCRlhfIPyhuHWeRL+tDroB3fVsoX08OU8hY=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    wrapGAppsHook3
    pkg-config
    # doc generation
    gnome-doc-utils
    which
    libxslt
    libxml2
  ];

  buildInputs = [
    glib
    gtk3
    expat
    itstool
    # at-spi2 needs dbus to be recognized by pkg-config
    at-spi2-core
    dbus
  ]
  ++ lib.optional speechSupport speechd-minimal;

  configureFlags = lib.optional (!speechSupport) "--disable-speech";
  enableParallelBuilding = true;

  prePatch = ''
    # tries to invoke git for something, probably fetching the ref
    echo "true" > build-aux/mkversion
  '';

  meta = {
    description = "Information-efficient text-entry interface, driven by natural continuous pointing gestures";
    homepage = "https://www.inference.org.uk/dasher/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "dasher";
  };
}
