{
  lib,
  stdenv,
  fetchurl,
  cacert,
  gdbm,
  libiconv,
  mbedtls,
  openssl,
  pkg-config,
  texinfo,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "gauche-bootstrap";
  version = "0.9.15";

  src = fetchurl {
    url = "https://github.com/shirok/Gauche/releases/download/release${
      lib.replaceStrings [ "." ] [ "_" ] version
    }/Gauche-${version}.tgz";

    hash = "sha256-NkPie8fIgiz9b7KJLbGF9ljo42STi8LM/O2yOeNa94M=";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    pkg-config
    texinfo
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
  enableParallelBuilding = true;

  meta = {
    description = "R7RS Scheme scripting engine (released version)";
    homepage = "https://practical-scheme.net/gauche/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mnacamura ];
    platforms = lib.platforms.unix;
    mainProgram = "gosh";
  };
}
