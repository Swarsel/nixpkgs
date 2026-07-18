{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libyubikey";
  version = "1.13";

  src = fetchurl {
    url = "https://developers.yubico.com/yubico-c/Releases/libyubikey-${finalAttrs.version}.tar.gz";
    sha256 = "009l3k2zyn06dbrlja2d4p2vfnzjhlcqxi88v02mlrnb17mx1v84";
  };

  meta = {
    description = "C library for manipulating Yubico YubiKey One-Time Passwords (OTPs)";
    homepage = "http://opensource.yubico.com/yubico-c/";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
  };
})
