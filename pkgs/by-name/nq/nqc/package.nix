{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nqc";
  version = "3.1.r6";

  src = fetchurl {
    url = "https://bricxcc.sourceforge.net/nqc/release/nqc-${finalAttrs.version}.tgz";
    sha256 = "sha256-v9XmVPY5r3pYjP3vTSK9Xvz/9UexClbOvr3ljvK/52Y=";
  };

  patches = [
    ./nqc-unistd.patch
    (fetchpatch {
      sha256 = "sha256-UZmmhhhfLAUus36TOBhiDQ8KUeEdYhGHVFwqKqDIqII=";
      url = "https://sourceforge.net/p/bricxcc/patches/_discuss/thread/00b427dc/b84b/attachment/nqc-01-Linux_usb_and_tcp.diff";
    })
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  dontConfigure = true;
  sourceRoot = ".";

  meta = {
    description = "Programming language for several LEGO MINDSTORMS products including the RCX, CyberMaster, and Scout";
    homepage = "https://bricxcc.sourceforge.net/nqc/";
    license = lib.licenses.mpl10;
    maintainers = with lib.maintainers; [ christophcharles ];
    platforms = lib.platforms.linux;
  };
})
