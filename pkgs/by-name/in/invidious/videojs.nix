{
  cacert,
  crystal,
  invidious,
  openssl,
  pkg-config,
  stdenvNoCC,
  versions,
}:

stdenvNoCC.mkDerivation {
  inherit (invidious) src;

  nativeBuildInputs = [
    cacert
    crystal
    openssl
    pkg-config
  ];

  builder = ./videojs.sh;
  name = "videojs";
  outputHash = versions.videojs.hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
