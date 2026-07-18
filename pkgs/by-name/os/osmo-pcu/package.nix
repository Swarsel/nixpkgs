{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libosmocore,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osmo-pcu";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "osmocom";
    repo = "osmo-pcu";
    rev = finalAttrs.version;
    hash = "sha256-ibcmR046Go6IAlMClUZFoTc/gpy/q5Mp0hJIx/4tKqo=";
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
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Osmocom Packet control Unit (PCU): Network-side GPRS (RLC/MAC); BTS- or BSC-colocated";
    homepage = "https://osmocom.org/projects/osmopcu";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux;
    mainProgram = "osmo-pcu";
  };
})
