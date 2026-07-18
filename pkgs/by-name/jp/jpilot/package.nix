{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk3,
  intltool,
  libgcrypt,
  pilot-link,
  pkg-config,
  sqlite,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jpilot";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "juddmon";
    repo = "jpilot";
    rev = "v${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-ja/P6kq53C7drEPWemGMV5fB4BktHrbrxL39jLEGhRI=";
  };

  patches = [ ./darwin-build.patch ]; # https://github.com/juddmon/jpilot/pull/59

  nativeBuildInputs = [
    autoreconfHook
    intltool
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libgcrypt
    sqlite
  ];

  configureFlags = [ "--with-pilot-prefix=${pilot-link}" ];

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  meta = {
    description = "Desktop organizer software for the Palm Pilot";
    homepage = "https://www.jpilot.org/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ PapayaJackal ];
    mainProgram = "jpilot";
  };
})
