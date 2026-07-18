{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libosmo-netif,
  libosmocore,
  linphonePackages,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libosmoabis";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "osmocom";
    repo = "libosmo-abis";
    rev = finalAttrs.version;
    hash = "sha256-jJD7XvwOBisN6womVSrY+V78KpFZ7WBvvh757dAS8y0=";
  };

  postPatch = ''
    echo "${finalAttrs.version}" > .tarball-version
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libosmocore
    libosmo-netif
    linphonePackages.ortp
    linphonePackages.bctoolbox
  ];

  configureFlags = [ "enable_dahdi=false" ];
  enableParallelBuilding = true;

  meta = {
    description = "Osmocom Abis interface library";
    homepage = "https://github.com/osmocom/libosmo-abis";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      markuskowa
    ];

    platforms = lib.platforms.linux;
  };
})
