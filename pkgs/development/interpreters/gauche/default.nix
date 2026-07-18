{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cacert,
  gaucheBootstrap,
  gdbm,
  libiconv,
  mbedtls,
  openssl,
  pkg-config,
  texinfo,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "gauche";
  version = "0.9.15";

  src = fetchFromGitHub {
    owner = "shirok";
    repo = "gauche";
    rev = "release${lib.replaceStrings [ "." ] [ "_" ] version}";
    hash = "sha256-M2vZqTMkob+WxUnCo4NDxS4pCVNleVBqkiiRp9nG/KA=";
  };

  postPatch = ''
    substituteInPlace ext/package-templates/configure \
      --replace "#!/usr/bin/env gosh" "#!$out/bin/gosh"
    patchShebangs .
  '';

  nativeBuildInputs = [
    gaucheBootstrap
    pkg-config
    texinfo
    autoreconfHook
  ];

  buildInputs = [
    libiconv
    gdbm
    openssl
    zlib
    mbedtls
    cacert
  ];

  configureFlags = [
    "--with-iconv=${libiconv}"
    "--with-dbm=gdbm"
    "--with-zlib=${zlib}"
    "--with-ca-bundle=${cacert}/etc/ssl/certs/ca-bundle.crt"
    # TODO: Enable slib
    #       Current slib in nixpkgs is specialized to Guile
    # "--with-slib=${slibGuile}/lib/slib"
  ];

  # TODO: Fix tests that fail in sandbox build
  doCheck = false;

  autoreconfPhase = ''
    ./DIST gen
  '';

  enableParallelBuilding = true;

  meta = {
    description = "R7RS Scheme scripting engine";
    homepage = "https://practical-scheme.net/gauche/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mnacamura ];
    platforms = lib.platforms.unix;
    mainProgram = "gosh";
  };
}
