{
  lib,
  stdenv,
  fetchurl,
  apr,
  aprutil,
  directoryListingUpdater,
  mod_ca,
  pkg-config,
}:

stdenv.mkDerivation rec {
  inherit (mod_ca) configureFlags installFlags;
  pname = "mod_pkcs12";
  version = "0.2.3";

  src = fetchurl {
    url = "https://redwax.eu/dist/rs/${pname}-${version}.tar.gz";
    hash = "sha256-k7BZ5d0WigyTmoUyFds7UCJ/tFBiUxd5pS4cVxmAI1g=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    apr
    aprutil
    mod_ca
  ];

  passthru.updateScript = directoryListingUpdater {
    url = "https://redwax.eu/dist/rs/";
  };

  meta = {
    description = "RedWax CA service modules for PKCS#12 format files";
    homepage = "https://redwax.eu";
    changelog = "https://source.redwax.eu/projects/RS/repos/mod_pkcs12/browse/ChangeLog";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dirkx ];
    platforms = lib.platforms.unix;
  };
}
