{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  doxygen,
  fetchpatch,
  openssl,
  pkg-config,
  python3,
  python3Packages,
  sqlite,
  wafHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ndn-cxx";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "named-data";
    repo = "ndn-cxx";
    rev = "ndn-cxx-${finalAttrs.version}";
    sha256 = "sha256-u9+QxqdCET1f5B54HF+Jk/YuQvhcYWsPNIVHi5l0XTM=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-ikVIJ8Jza17k/sa/wtu2EUGLEhUMloMOkBrMN9W9BPY=";
      name = "fix-gcc15.patch";
      url = "https://github.com/named-data/ndn-cxx/commit/0ba3d3a9d9701be4baa3969fe50e97e89d11249b.patch";
    })
  ];

  nativeBuildInputs = [
    doxygen
    pkg-config
    python3
    python3Packages.sphinx
    wafHook
  ];

  buildInputs = [
    boost
    openssl
    sqlite
  ];

  doCheck = false; # some tests fail in upstream, some fail because of the sandbox environment

  checkPhase = ''
    runHook preCheck
    LD_PRELOAD=build/libndn-cxx.so build/unit-tests
    runHook postCheck
  '';

  wafConfigureFlags = [
    "--with-openssl=${openssl.dev}"
    "--boost-includes=${boost.dev}/include"
    "--boost-libs=${boost.out}/lib"
    "--with-tests"
  ];

  meta = {
    description = "Named Data Networking (NDN) or Content Centric Networking (CCN) abstraction";

    longDescription = ''
      ndn-cxx is a C++ library, implementing Named Data Networking (NDN)
      primitives that can be used to implement various NDN applications.
      NDN operates by addressing and delivering Content Objects directly
      by Name instead of merely addressing network end-points. In addition,
      the NDN security model explicitly secures individual Content Objects
      rather than securing the connection or “pipe”. Named and secured
      content resides in distributed caches automatically populated on
      demand or selectively pre-populated. When requested by name, NDN
      delivers named content to the user from the nearest cache, thereby
      traversing fewer network hops, eliminating redundant requests,
      and consuming less resources overall.
    '';

    homepage = "https://named-data.net/";
    license = lib.licenses.lgpl3;

    maintainers = with lib.maintainers; [
      bertof
    ];

    platforms = lib.platforms.unix;
  };
})
