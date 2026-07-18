{
  lib,
  stdenv,
  fetchurl,
  libmnl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnetfilter_acct";
  version = "1.0.3";

  src = fetchurl {
    url = "https://www.netfilter.org/projects/libnetfilter_acct/files/libnetfilter_acct-${finalAttrs.version}.tar.bz2";
    sha256 = "06lsjndgfjsgfjr43px2n2wk3nr7whz6r405mks3887y7vpwwl22";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libmnl ];

  meta = {
    description = "Userspace library providing interface to extended accounting infrastructure";
    homepage = "https://www.netfilter.org/projects/libnetfilter_acct/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
