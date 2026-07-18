{
  lib,
  stdenv,
  autoconf,
  automake,
  autoreconfHook,
  expat,
  fetchgit,
  gawk,
  gd,
  gettext,
  glibcLocales,
  gmp,
  hiredis,
  libharu,
  libiconv,
  libpq,
  libtool,
  lmdb,
  more,
  mpfr,
  pkg-config,
  rapidjson,
  texinfo,
  tre,
}:

let
  buildExtension = lib.makeOverridable (
    {
      gawkextlib,
      name,
      broken ? null,
      doCheck ? true,
      env ? { },
      extraBuildInputs ? [ ],
      extraPostPatch ? "",
      patches ? [ ],
    }:
    let
      is_extension = gawkextlib != null;
    in
    stdenv.mkDerivation rec {
      inherit patches;
      inherit gawk;
      inherit env;
      inherit doCheck;
      pname = "gawkextlib-${name}";
      version = "unstable-2022-10-20";

      src = fetchgit {
        url = "git://git.code.sf.net/p/gawkextlib/code";
        rev = "f6c75b4ac1e0cd8d70c2f6c7a8d58b4d94cfde97";
        sha256 = "sha256-0p3CrQ3TBl7UcveZytK/9rkAzn69RRM2GwY2eCeqlkg=";
      };

      postPatch = ''
        cd ${name}
      ''
      + extraPostPatch;

      nativeBuildInputs = [
        autoconf
        automake
        libtool
        autoreconfHook
        pkg-config
        texinfo
        gettext
      ];

      buildInputs = [ gawk ] ++ extraBuildInputs;
      propagatedBuildInputs = lib.optional is_extension gawkextlib;
      nativeCheckInputs = [ more ];
      setupHook = if is_extension then ./setup-hook.sh else null;

      meta = {
        description = "Dynamically loaded extension libraries for GNU AWK";

        longDescription = ''
          The gawkextlib project provides several extension libraries for
          gawk (GNU AWK), as well as libgawkextlib containing some APIs that
          are useful for building gawk extension libraries. These libraries
          enable gawk to process XML data, interact with a PostgreSQL
          database, use the GD graphics library, and perform unlimited
          precision MPFR calculations.
        '';

        homepage = "https://sourceforge.net/projects/gawkextlib/";
        license = lib.licenses.gpl3Plus;
        maintainers = with lib.maintainers; [ tomberek ];
        platforms = lib.platforms.unix;
        mainProgram = "xmlgawk";
      }
      // lib.optionalAttrs (broken != null) { inherit broken; };
    }
  );
  gawkextlib = buildExtension {
    gawkextlib = null;
    name = "lib";
  };
  libs = {
    abort = buildExtension {
      inherit gawkextlib;
      name = "abort";
    };

    aregex = buildExtension {
      inherit gawkextlib;
      extraBuildInputs = [ tre ];
      name = "aregex";
    };

    csv = buildExtension {
      inherit gawkextlib;
      name = "csv";
    };

    errno = buildExtension {
      inherit gawkextlib;

      extraPostPatch = ''
        substituteInPlace Makefile.am --replace-fail 'cpp -M' '${stdenv.cc.targetPrefix}cpp -M'
      '';

      name = "errno";
    };

    gd = buildExtension {
      inherit gawkextlib;
      # GCC 14 makes this an error by default, remove when fixed upstream
      env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
      extraBuildInputs = [ gd ];
      name = "gd";
    };

    haru = buildExtension {
      inherit gawkextlib;

      patches = [
        # Renames references to two identifiers with typos that libharu fixed in 2.4.4
        # https://github.com/libharu/libharu/commit/88271b73c68c521a49a15e3555ef00395aa40810
        ./fix-typos-corrected-in-libharu-2.4.4.patch
      ];

      # GCC 14 makes this an error by default, remove when fixed upstream
      env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
      extraBuildInputs = [ libharu ];
      name = "haru";
    };

    json = buildExtension {
      inherit gawkextlib;
      extraBuildInputs = [ rapidjson ];
      name = "json";
    };

    lmdb = buildExtension {
      inherit gawkextlib;
      #  mdb_env_open(env, /dev/null)
      #! No such device
      #  mdb_env_open(env, /dev/null)
      #! Operation not supported by device
      doCheck = !stdenv.hostPlatform.isDarwin;
      extraBuildInputs = [ lmdb ];

      extraPostPatch = ''
        substituteInPlace Makefile.am --replace-fail 'cpp -M' '${stdenv.cc.targetPrefix}cpp -M'
      '';

      name = "lmdb";
    };

    mbs = buildExtension {
      inherit gawkextlib;
      #! "spät": length: 5, mbs_length: 6, wcswidth: 4
      doCheck = !stdenv.hostPlatform.isDarwin;
      extraBuildInputs = [ glibcLocales ];
      name = "mbs";
    };

    mpfr = buildExtension {
      inherit gawkextlib;

      extraBuildInputs = [
        gmp
        mpfr
      ];

      name = "mpfr";
    };

    nl_langinfo = buildExtension {
      inherit gawkextlib;
      name = "nl_langinfo";
    };

    pgsql = buildExtension {
      inherit gawkextlib;
      extraBuildInputs = [ libpq ];
      name = "pgsql";
    };

    redis = buildExtension {
      inherit gawkextlib;
      extraBuildInputs = [ hiredis ];
      name = "redis";
    };

    select = buildExtension {
      inherit gawkextlib;

      extraPostPatch = ''
        substituteInPlace Makefile.am --replace-fail 'cpp -M' '${stdenv.cc.targetPrefix}cpp -M'
      '';

      name = "select";
    };

    timex = buildExtension {
      inherit gawkextlib;
      name = "timex";
    };

    xml = buildExtension {
      inherit gawkextlib;
      # gawk: xmlbase:14: fatal: load_ext: cannot open library `../.libs/xml.so`
      broken = !stdenv.buildPlatform.canExecute stdenv.hostPlatform;

      extraBuildInputs = [
        expat
        libiconv
      ];

      name = "xml";
    };
  };
in
lib.recurseIntoAttrs (
  libs
  // {
    inherit gawkextlib buildExtension;
    full = builtins.attrValues libs;
  }
)
