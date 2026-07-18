args:
{
  lib,
  stdenv,
  fetchFromGitHub,
  cctools,
  coreutils,
  darwin,
  libiconv,
  libx11,
  lz4,
  ncurses,
  zlib,
}:

stdenv.mkDerivation (
  args
  // {
    version = "unstable-2021-12-11";

    src = fetchFromGitHub {
      owner = "racket";
      repo = "ChezScheme";
      rev = "8846c96b08561f05a937d5ecfe4edc96cc99be39";
      sha256 = "IYJQzT88T8kFahx2BusDOyzz6lQDCbZIfSz9rZoNF7A=";
      fetchSubmodules = true;
    };

    postPatch = ''
      export ZLIB="$(find ${zlib.out}/lib -type f | sort | head -n1)"
      export LZ4="$(find ${lz4.lib}/lib -type f | sort | head -n1)"
    '';

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
      cctools
      darwin.autoSignDarwinBinariesHook
    ];

    buildInputs = [
      libiconv
      libx11
      lz4
      ncurses
      zlib
    ];

    env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isGNU "-Wno-error=format-truncation";
    enableParallelBuilding = true;

    prePatch = ''
      rm -rf zlib/*.c lz4/lib/*.c
    '';

    meta = {
      description = "Fork of Chez Scheme for Racket";
      homepage = "https://github.com/racket/ChezScheme";
      license = lib.licenses.asl20;
      maintainers = [ ];
      platforms = lib.platforms.unix;
    };
  }
)
