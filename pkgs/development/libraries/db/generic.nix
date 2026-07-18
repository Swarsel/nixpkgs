{
  lib,
  stdenv,
  fetchurl,
  autoconf269,
  autoreconfHook,
  fetchpatch,
  sha256,
  # Options from inherited versions
  version,
  compat185 ? true,
  cxxSupport ? true,
  dbmSupport ? false,
  drvArgs ? { },
  extraPatches ? [ ],
  license ? lib.licenses.sleepycat,
}:

stdenv.mkDerivation (
  rec {
    inherit version;
    pname = "db";

    src = fetchurl {
      url = "https://download.oracle.com/berkeley-db/db-${version}.tar.gz";
      sha256 = sha256;
    };

    outputs = [
      "bin"
      "out"
      "dev"
    ];

    patches = [
      (fetchpatch {
        hash = "sha256-OzQL+kgXtcvhvyleDLuH1abhY4Shb/9IXx4ZkeFbHOA=";
        name = "gcc15.patch";
        url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-libs/db/files/db-4.8.30-tls-configure.patch?id=1ae36006c79ef705252f5f7009e79f6add7dc353";
      })
    ]
    ++ extraPatches;

    # autoreconfHook: the provided configure script features `main` returning implicit `int`,
    # which causes configure checks to work incorrectly with clang 16.
    nativeBuildInputs = lib.optionals stdenv.cc.isClang [ autoconf269 ] ++ [ autoreconfHook ];

    configureFlags = [
      (if cxxSupport then "--enable-cxx" else "--disable-cxx")
      (if compat185 then "--enable-compat185" else "--disable-compat185")
    ]
    ++ lib.optional dbmSupport "--enable-dbm"
    ++ lib.optional stdenv.hostPlatform.isFreeBSD "--with-pic";

    env.NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=incompatible-pointer-types"
    ];

    preConfigure = ''
      cd build_unix
      configureScript=../dist/configure
    '';

    doCheck = true;

    checkPhase = ''
      make examples_c examples_cxx
    '';

    postInstall = ''
      rm -rf $out/docs
    '';

    # Required when regenerated the configure script to make sure the vendored macros are found.
    autoreconfFlags = [
      "-fi"
      "-Iaclocal"
      "-Iaclocal_java"
    ];

    enableParallelBuilding = true;

    # This isn’t pretty. The version information is kept separate from the configure script.
    # After the configure script is regenerated, the version information has to be replaced with the
    # contents of `dist/RELEASE`.
    postAutoreconf = ''
      (
        declare -a vars=(
          "DB_VERSION_FAMILY"
          "DB_VERSION_RELEASE"
          "DB_VERSION_MAJOR"
          "DB_VERSION_MINOR"
          "DB_VERSION_PATCH"
          "DB_VERSION_STRING"
          "DB_VERSION_FULL_STRING"
          "DB_VERSION_UNIQUE_NAME"
          "DB_VERSION"
        )
        source RELEASE
        for var in "''${vars[@]}"; do
          sed -e "s/__EDIT_''${var}__/''${!var}/g" -i configure
        done
      )
      popd
    '';

    preAutoreconf = ''
      pushd dist
      # Upstream’s `dist/s_config` cats everything into `aclocal.m4`, but that doesn’t work with
      # autoreconfHook, so cat `config.m4` to another file. Otherwise, it won’t be found by `aclocal`.
      cat aclocal/config.m4 >> aclocal/options.m4
    '';

    meta = {
      description = "Berkeley DB";
      homepage = "https://www.oracle.com/database/technologies/related/berkeleydb.html";
      license = license;
      platforms = lib.platforms.unix;
    };
  }
  // drvArgs
)
