{
  lib,
  stdenv,
  fetchFromGitLab,
  boost,
  gcc,
  getopt,
  libxcrypt,
  lua,
  perl,
  pkg-config,
  swig,
}:

let
  self = stdenv.mkDerivation rec {
    pname = "highlight";
    version = "4.20";

    src = fetchFromGitLab {
      owner = "saalen";
      repo = "highlight";
      rev = "v${version}";
      hash = "sha256-fMIyMR9RA60hdy1eniJkvLHK+WJPuVehWMyS9Lt6iQ4=";
    };

    postPatch = ''
      substituteInPlace src/makefile \
        --replace "shell pkg-config" "shell $PKG_CONFIG"
      substituteInPlace makefile \
        --replace 'gzip' 'gzip -n'
    ''
    + lib.optionalString stdenv.cc.isClang ''
      substituteInPlace src/makefile \
          --replace 'CXX=g++' 'CXX=clang++'
    '';

    nativeBuildInputs = [
      pkg-config
      swig
      perl
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin gcc;

    buildInputs = [
      getopt
      lua
      boost
      libxcrypt
    ];

    preConfigure = ''
      makeFlags="PREFIX=$out conf_dir=$out/etc/highlight/ CXX=$CXX AR=$AR"
    '';

    # This has to happen _before_ the main build because it does a
    # `make clean' for some reason.
    preBuild = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      make -C extras/swig $makeFlags perl
    '';

    postCheck = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      perl -Iextras/swig extras/swig/testmod.pl
    '';

    preInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      mkdir -p $out/${perl.libPrefix}
      install -m644 extras/swig/highlight.{so,pm} $out/${perl.libPrefix}
      make -C extras/swig clean # Clean up intermediate files.
    '';

    enableParallelBuilding = true;

    meta = {
      description = "Source code highlighting tool";
      homepage = "http://www.andre-simon.de/doku/highlight/en/highlight.php";
      maintainers = [ ];
      platforms = lib.platforms.unix;
      mainProgram = "highlight";
    };
  };

in
if stdenv.hostPlatform.isDarwin then self else perl.pkgs.toPerlModule self
