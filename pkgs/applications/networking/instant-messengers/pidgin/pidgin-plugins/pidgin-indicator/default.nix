{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  glib,
  intltool,
  libappindicator-gtk2,
  libtool,
  pidgin,
}:

stdenv.mkDerivation rec {
  pname = "pidgin-indicator";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "philipl";
    repo = "pidgin-indicator";
    rev = version;
    sha256 = "sha256-CdA/aUu+CmCRbVBKpJGydicqFQa/rEsLWS3MBKlH2/M=";
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
  ];

  buildInputs = [
    glib
    libappindicator-gtk2
    libtool
    pidgin
  ];

  meta = {
    description = "AppIndicator and KStatusNotifierItem Plugin for Pidgin";
    homepage = "https://github.com/philipl/pidgin-indicator";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ imalison ];
    platforms = with lib.platforms; linux;
  };
}
