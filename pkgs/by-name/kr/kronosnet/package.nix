{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bzip2,
  doxygen,
  libnl,
  libqb,
  libxml2,
  lksctp-tools,
  lz4,
  lzo,
  nss,
  openssl,
  pkg-config,
  xz,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kronosnet";
  version = "1.33";

  src = fetchFromGitHub {
    owner = "kronosnet";
    repo = "kronosnet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mLpHV54BqYmWNjkoNt2v/lu/QfMwkHeMgMUCDEGeUPI=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    doxygen
  ];

  buildInputs = [
    libqb
    libxml2
    libnl
    lksctp-tools
    nss
    openssl
    bzip2
    lzo
    lz4
    xz
    zlib
    zstd
  ];

  meta = {
    description = "VPN on steroids";
    homepage = "https://kronosnet.org/";

    license = with lib.licenses; [
      lgpl21Plus
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [ ryantm ];
  };
})
