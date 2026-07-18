{
  lib,
  stdenv,
  fetchurl,
  getopt,
  makeWrapper,
  postgresql,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ephemeralpg";
  version = "3.4";

  src = fetchurl {
    url = "https://eradman.com/ephemeralpg/code/ephemeralpg-${finalAttrs.version}.tar.gz";
    hash = "sha256-IwAIJFW/ahDXGgINi4N9mG3XKw74JXK6+SLxGMZ8tS0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out
    PREFIX=$out make install
    wrapProgram $out/bin/pg_tmp --prefix PATH : ${
      lib.makeBinPath [
        postgresql
        getopt
      ]
    }
  '';

  meta = {
    description = "Run tests on an isolated, temporary PostgreSQL database";
    homepage = "https://eradman.com/ephemeralpg/";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      medv
    ];

    platforms = lib.platforms.all;
  };
})
