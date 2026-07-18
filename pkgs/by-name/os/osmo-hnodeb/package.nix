{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libasn1c,
  libosmo-netif,
  libosmo-sigtran,
  libosmoabis,
  libosmocore,
  lksctp-tools,
  osmo-iuh,
  pkg-config,
}:

let
  inherit (stdenv.hostPlatform) isLinux;
in

stdenv.mkDerivation rec {
  pname = "osmo-hnodeb";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "osmocom";
    repo = "osmo-hnodeb";
    rev = version;
    hash = "sha256-Izivyw2HqRmrM68ehGqlIkJeuZ986d1WQ0yr6NWWTdA=";
  };

  postPatch = ''
    echo "${version}" > .tarball-version
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libosmocore
    lksctp-tools
    libasn1c
    libosmoabis
    libosmo-netif
    libosmo-sigtran
    osmo-iuh
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Upper layers implementation of HomeNodeB for 3G/UMTS";
    homepage = "https://osmocom.org/projects/osmo-hnodeb";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "osmo-hnodeb";
  };
}
