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
  pname = "mod_scep";
  version = "0.2.4";

  src = fetchurl {
    url = "https://redwax.eu/dist/rs/${pname}-${version}.tar.gz";
    hash = "sha256-HFPQ1A3ULtT2MduIQZS1drdQvCdZqJqKpOsJLEw67sI=";
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
    description = "RedWax CA service modules for SCEP (Automatic ceritifcate issue/renewal)";
    homepage = "https://redwax.eu";
    changelog = "https://source.redwax.eu/projects/RS/repos/mod_scep/browse/ChangeLog";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dirkx ];
    platforms = lib.platforms.unix;
  };
}
