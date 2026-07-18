{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoreconfHook,
  libxmp,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "xmp";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "libxmp";
    repo = "xmp-cli";
    rev = "${pname}-${version}";
    hash = "sha256-bHepVTkh7Gu8ea/WW5bY7zTiqYWpENlsPqsMV+4WVT4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ libxmp ] ++ lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];

  meta = {
    description = "Extended module player";
    homepage = "https://xmp.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "xmp";
  };
}
