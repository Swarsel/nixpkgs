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
  pname = "mod_crl";
  version = "0.2.4";

  src = fetchurl {
    url = "https://redwax.eu/dist/rs/${pname}-${version}.tar.gz";
    hash = "sha256-w8YIhed9J1uo5uwhfOVe5LhNLUvFZCgUO4FrHm344Rg=";
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
    description = "RedWax module for Certificate Revocation Lists";
    homepage = "https://redwax.eu";
    changelog = "https://source.redwax.eu/projects/RS/repos/mod_crl/browse/ChangeLog";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dirkx ];
    platforms = lib.platforms.unix;
  };
}
