{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  libimobiledevice-glue,
  libplist,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtatsu";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "libtatsu";
    tag = finalAttrs.version;
    hash = "sha256-vf4xBTTGDJCTj4TMLOhojjAfzSbkx+ogGBnf+UeumG0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libplist
    libimobiledevice-glue
    curl
  ];

  preAutoreconf = ''
    echo ${finalAttrs.version} > .tarball-version
    export PACKAGE_VERSION=${finalAttrs.version}
  '';

  meta = {
    description = "Library handling the communication with Apple's Tatsu Signing Server (TSS)";
    homepage = "https://github.com/libimobiledevice/libtatsu";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ nxm ];
    platforms = lib.platforms.unix;
  };
})
