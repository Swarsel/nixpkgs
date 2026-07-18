{
  lib,
  stdenv,
  fetchurl,
  apr,
  aprutil,
  fetchpatch,
  libiconv,
  libkrb5,
  openssl,
  pkg-config,
  scons,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "serf";
  version = "1.3.10";

  src = fetchurl {
    url = "mirror://apache/serf/serf-${finalAttrs.version}.tar.bz2";
    hash = "sha256-voHvCLqiUW7Np2p3rffe97wyJ+61eLmjO0X3tB3AZOY=";
  };

  patches = [
    ./scons.patch

    (fetchpatch {
      hash = "sha256-FQJvXOIZ0iItvbbcu4kR88j74M7fOi7C/0NN3o1/ub4=";
      url = "https://src.fedoraproject.org/rpms/libserf/raw/rawhide/f/libserf-1.3.9-errgetfunc.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    scons
  ];

  buildInputs = [
    apr
    openssl
    aprutil
    zlib
    libiconv
  ]
  ++ lib.optional (!stdenv.hostPlatform.isCygwin) libkrb5;

  preConfigure = ''
    appendToVar sconsFlags "APR=$(echo ${apr.dev}/bin/*-config)"
    appendToVar sconsFlags "APU=$(echo ${aprutil.dev}/bin/*-config)"
    appendToVar sconsFlags "CC=$CC"
    appendToVar sconsFlags "OPENSSL=${openssl}"
    appendToVar sconsFlags "ZLIB=${zlib}"
  ''
  + lib.optionalString (!stdenv.hostPlatform.isCygwin) ''
    appendToVar sconsFlags "GSSAPI=${libkrb5.dev}"
  '';

  enableParallelBuilding = true;
  prefixKey = "PREFIX=";

  meta = {
    description = "HTTP client library based on APR";
    homepage = "https://serf.apache.org/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
