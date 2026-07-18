{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gettext,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lrzsz";
  version = "0.12.20";

  src = fetchurl {
    url = "https://ohse.de/uwe/releases/lrzsz-${finalAttrs.version}.tar.gz";
    sha256 = "1wcgfa9fsigf1gri74gq0pa7pyajk12m4z69x7ci9c6x9fqkd2y2";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2018-10195.patch";
      sha256 = "0jlh8w0cjaz6k56f0h3a0h4wgc51axmrdn3mdspk7apjfzqcvx3c";
      url = "https://bugzilla.redhat.com/attachment.cgi?id=79507";
    })
  ];

  nativeBuildInputs = [ gettext ];
  configureFlags = [ "--program-transform-name=s/^l//" ];
  makeFlags = [ "AR:=$(AR)" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=incompatible-pointer-types -std=gnu17";
  hardeningDisable = [ "format" ];

  meta = {
    description = "Communication package providing the XMODEM, YMODEM ZMODEM file transfer protocols";
    homepage = "https://ohse.de/uwe/software/lrzsz.html";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
