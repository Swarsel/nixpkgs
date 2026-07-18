{
  lib,
  stdenv,
  fetchurl,
  fixDarwinDylibNames,
  gitUpdater,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mujs";
  version = "1.3.6";

  src = fetchurl {
    url = "https://mujs.com/downloads/mujs-${finalAttrs.version}.tar.gz";
    hash = "sha256-fPOl5iLP9BkD7/8DNFGPyUrwYyVnUsOLpGGKUZHkTxg=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ fixDarwinDylibNames ];
  buildInputs = [ readline ];
  makeFlags = [ "prefix=$(out)" ];
  installFlags = [ "install-shared" ];

  passthru.updateScript = gitUpdater {
    # No nicer place to track releases
    url = "git://git.ghostscript.com/mujs.git";
  };

  meta = {
    description = "Lightweight, embeddable Javascript interpreter";
    homepage = "https://mujs.com/";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.unix;
  };
})
