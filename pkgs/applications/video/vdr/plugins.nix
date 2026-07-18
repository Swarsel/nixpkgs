{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  callPackage,
  graphicsmagick,
  libgcrypt,
  ncurses,
  vdr,
}:
let
  mkPlugin =
    name:
    stdenv.mkDerivation {
      inherit (vdr) src version;
      pname = name;
      buildInputs = [ vdr ];
      preConfigure = "cd PLUGINS/src/${name}";
      installFlags = [ "DESTDIR=$(out)" ];

      meta = {
        homepage = "https://git.tvdr.de/?p=vdr.git";
      };
    };
in
{

  epgsearch = callPackage ./epgsearch { };

  fritzbox = stdenv.mkDerivation rec {
    pname = "vdr-fritzbox";
    version = "1.5.8";

    src = fetchFromGitHub {
      owner = "jowi24";
      repo = "vdr-fritz";
      rev = version;
      hash = "sha256-o+wJJCAOTg6pPScZ0iIiEWZyT2/++pLtuOppNeaXzmQ=";
      fetchSubmodules = true;
    };

    buildInputs = [
      vdr
      boost
      libgcrypt
    ];

    installFlags = [ "DESTDIR=$(out)" ];

    meta = {
      inherit (src.meta) homepage;
      inherit (vdr.meta) platforms;
      description = "Plugin for VDR to access AVMs Fritz Box routers";
      license = lib.licenses.gpl2;
      maintainers = [ lib.maintainers.ck3d ];
    };
  };

  markad = callPackage ./markad { };
  nopacity = callPackage ./nopacity { };

  skincurses = (mkPlugin "skincurses").overrideAttrs (oldAttr: {
    buildInputs = oldAttr.buildInputs ++ [ ncurses ];
  });

  softhddevice = callPackage ./softhddevice { };
  streamdev = callPackage ./streamdev { };

  text2skin = stdenv.mkDerivation rec {
    pname = "vdr-text2skin";
    version = "1.3.4-20170702";

    src = fetchFromGitHub {
      owner = "vdr-projects";
      repo = "vdr-plugin-text2skin";
      rev = "8f7954da2488ced734c30e7c2704b92a44e6e1ad";
      sha256 = "19hkwmaw6nwak38bv6cm2vcjjkf4w5yjyxb98qq6zfjjh5wq54aa";
    };

    buildInputs = [
      vdr
      graphicsmagick
    ];

    buildFlags = [
      "DESTDIR=$(out)"
      "IMAGELIB=graphicsmagic"
      "VDRDIR=${vdr.dev}/include/vdr"
      "LOCALEDIR=$(DESTDIR)/share/locale"
      "LIBDIR=$(DESTDIR)/lib/vdr"
    ];

    preBuild = ''
      mkdir -p $out/lib/vdr
    '';

    dontInstall = true;

    meta = {
      inherit (src.meta) homepage;
      inherit (vdr.meta) platforms;
      description = "VDR Text2Skin Plugin";
      license = lib.licenses.gpl2;
      maintainers = [ lib.maintainers.ck3d ];
    };
  };

  vnsiserver = stdenv.mkDerivation rec {
    pname = "vdr-vnsiserver";
    version = "1.8.4";

    src = fetchFromGitHub {
      owner = "vdr-projects";
      repo = "vdr-plugin-vnsiserver";
      rev = version;
      sha256 = "sha256-EFPY1Pt79reL05Tdu14HYE9E+CnT9mdUYifGzTsNpMA=";
    };

    buildInputs = [ vdr ];
    installFlags = [ "DESTDIR=$(out)" ];

    meta = {
      inherit (src.meta) homepage;
      inherit (vdr.meta) platforms;
      description = "VDR plugin to handle KODI clients";
      license = lib.licenses.gpl2;
      maintainers = [ lib.maintainers.ck3d ];
    };

  };

  xineliboutput = callPackage ./xineliboutput { };
}
// (lib.genAttrs [
  "epgtableid0"
  "hello"
  "osddemo"
  "pictures"
  "servicedemo"
  "status"
  "svdrpdemo"
] mkPlugin)
