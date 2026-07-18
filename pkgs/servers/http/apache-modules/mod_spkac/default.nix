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
  pname = "mod_spkac";
  version = "0.2.3";

  src = fetchurl {
    url = "https://redwax.eu/dist/rs/${pname}-${version}.tar.gz";
    hash = "sha256-J1pGz+/AD0IPwRPBA+wt9PgV9qnZEHX66VCBGqhf0b8=";
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
    description = "RedWax CA service module for handling the Netscape keygen requests";
    homepage = "https://redwax.eu";
    changelog = "https://source.redwax.eu/projects/RS/repos/mod_spkac/browse/ChangeLog";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dirkx ];
    platforms = lib.platforms.unix;
  };
}
