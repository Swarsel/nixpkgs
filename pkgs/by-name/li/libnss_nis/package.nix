{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libnsl,
  libtirpc,
  libxcrypt,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnss_nis";
  version = "3.4";

  src = fetchFromGitHub {
    owner = "thkukuk";
    repo = "libnss_nis";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FWAyf4soSUpNrYzSefNWthEMfQEopfYX9pMDf1rNK6c=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libxcrypt
    libnsl
    libtirpc
  ];

  meta = {
    description = "NSS module for glibc, to provide NIS support for glibc";
    homepage = "https://github.com/thkukuk/libnss_nis";
    changelog = "https://github.com/thkukuk/libnss_nis/blob/master/NEWS";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ BarrOff ];
    platforms = lib.platforms.linux;
  };
})
