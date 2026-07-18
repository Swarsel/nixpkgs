{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  openssl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libre";
  version = "4.9.0";

  src = fetchFromGitHub {
    owner = "baresip";
    repo = "re";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-0g3L+2PYLjnc2MyFhPX6exy+84oohP24As34oMBzO9k=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    openssl
    zlib
  ];

  makeFlags = [
    "USE_ZLIB=1"
    "USE_OPENSSL=1"
    "PREFIX=$(out)"
  ]
  ++ lib.optional (stdenv.cc.cc != null) "SYSROOT_ALT=${stdenv.cc.cc}"
  ++ lib.optional (stdenv.cc.libc != null) "SYSROOT=${lib.getDev stdenv.cc.libc}";

  enableParallelBuilding = true;

  meta = {
    description = "Library for real-time communications with async IO support and a complete SIP stack";
    homepage = "https://github.com/baresip/re";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ raskin ];
  };
})
