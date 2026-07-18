{
  lib,
  stdenv,
  fetchurl,
  colm,
  fig2dev,
  ghostscript,
  texliveSmall,
  build-manual ? false,
}:

let
  generic =
    {
      license,
      sha256,
      version,
      broken ? false,
    }:
    stdenv.mkDerivation rec {
      inherit version;
      pname = "ragel";

      src = fetchurl {
        inherit sha256;
        url = "https://www.colm.net/files/ragel/${pname}-${version}.tar.gz";
      };

      buildInputs = lib.optionals build-manual [
        fig2dev
        ghostscript
        texliveSmall
      ];

      configureFlags = [ "--with-colm=${colm}" ];
      env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isGNU "-std=gnu++98";

      preConfigure = lib.optionalString build-manual ''
        sed -i "s/build_manual=no/build_manual=yes/g" DIST
      '';

      doCheck = true;
      enableParallelBuilding = true;

      meta = {
        inherit broken license;
        description = "State machine compiler";
        homepage = "https://www.colm.net/open-source/ragel/";
        maintainers = with lib.maintainers; [ pSub ];
        platforms = lib.platforms.unix;
        mainProgram = "ragel";
      };
    };

in

{
  ragelDev = generic {
    version = "7.0.0.12";
    broken = stdenv.hostPlatform.isDarwin;
    license = lib.licenses.mit;
    sha256 = "0x3si355lv6q051lgpg8bpclpiq5brpri5lv3p8kk2qhzfbyz69r";
  };

  ragelStable = generic {
    version = "6.10";
    license = lib.licenses.gpl2;
    sha256 = "0gvcsl62gh6sg73nwaxav4a5ja23zcnyxncdcdnqa2yjcpdnw5az";
  };
}
