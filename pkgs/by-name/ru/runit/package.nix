{
  lib,
  stdenv,
  fetchurl,

  # Build runit-init as a static binary
  static ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "runit";
  version = "2.3.1";

  src = fetchurl {
    url = "https://smarden.org/runit/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    hash = "sha256-Y08jyMTR1EAEO+D+ko3fkEYmKJ6Xv+fFgm6TqvLMb+k=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    ./fix-ar-ranlib.patch
  ];

  postPatch = ''
    sed -i "s,\(#define RUNIT\) .*,\1 \"$out/bin/runit\"," src/runit.h
    # usernamespace sandbox of nix seems to conflict with runit's assumptions
    # about unix users. Therefor skip the check
    sed -i '/.\/chkshsgr/d' src/Makefile
  ''
  + lib.optionalString (!static) ''
    sed -i 's,-static,,g' src/Makefile
  '';

  buildInputs = lib.optionals static [
    stdenv.cc.libc
    stdenv.cc.libc.static
  ];

  preBuild = ''
    cd src

    # Both of these are originally hard-coded to gcc
    echo ${stdenv.cc.targetPrefix}cc > conf-cc
    echo ${stdenv.cc.targetPrefix}cc ${lib.optionalString stdenv.hostPlatform.isDarwin "-Xlinker -x "}> conf-ld
  '';

  doCheck = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -t $out/bin $(< ../package/commands)

    mkdir -p $man/share/man
    cp -r ../man $man/share/man/man8
  '';

  enableParallelBuilding = true;
  sourceRoot = "admin/${finalAttrs.pname}-${finalAttrs.version}";

  meta = {
    description = "UNIX init scheme with service supervision";
    homepage = "http://smarden.org/runit";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "runit";
  };
})
