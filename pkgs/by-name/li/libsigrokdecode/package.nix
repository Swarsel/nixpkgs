{
  lib,
  stdenv,
  autoreconfHook,
  check,
  fetchgit,
  glib,
  libxcrypt,
  pkg-config,
  python3,
}:

stdenv.mkDerivation {
  pname = "libsigrokdecode";
  version = "0.5.3-unstable-2024-10-01";

  src = fetchgit {
    url = "git://sigrok.org/libsigrokdecode";
    rev = "71f451443029322d57376214c330b518efd84f88";
    hash = "sha256-aW0llB/rziJxLW3OZU1VhxeM3MDWsaMVVgvDKZzdiIY=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    glib
    python3
    libxcrypt
  ];

  doCheck = true;
  nativeCheckInputs = [ check ];

  meta = {
    description = "Protocol decoding library for the sigrok signal analysis software suite";
    homepage = "https://sigrok.org/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      bjornfor
      vifino
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
