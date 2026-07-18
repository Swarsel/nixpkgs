{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libimobiledevice-glue,
  libplist,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libusbmuxd";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "libusbmuxd";
    rev = finalAttrs.version;
    hash = "sha256-o1EFY/cv+pQrGexvPOwMs5mz9KRcffnloXCQXMzbmDY=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libplist
    libimobiledevice-glue
  ];

  preAutoreconf = ''
    export RELEASE_VERSION=${finalAttrs.version}
  '';

  meta = {
    description = "Client library to multiplex connections from and to iOS devices";
    homepage = "https://github.com/libimobiledevice/libusbmuxd";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
