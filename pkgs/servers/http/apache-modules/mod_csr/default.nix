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
  pname = "mod_csr";
  version = "0.2.4";

  src = fetchurl {
    url = "https://redwax.eu/dist/rs/${pname}-${version}.tar.gz";
    hash = "sha256-JVd5N5UnAxDwq6AavEHA0HsY2TRa+9RmLLJeRZbj+4Q=";
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
    description = "RedWax CA service module to handle Certificate Signing Requests";
    homepage = "https://redwax.eu";
    changelog = "https://source.redwax.eu/projects/RS/repos/mod_csr/browse/ChangeLog";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dirkx ];
    platforms = lib.platforms.unix;
  };
}
