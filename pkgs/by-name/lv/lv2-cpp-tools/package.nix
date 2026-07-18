{
  lib,
  stdenv,
  boost,
  fetchzip,
  gtkmm2,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lv2-cpp-tools";
  version = "1.0.5";

  src = fetchzip {
    url = "https://deb.debian.org/debian/pool/main/l/lv2-c++-tools/lv2-c++-tools_${finalAttrs.version}.orig.tar.bz2";
    sha256 = "039bq7d7s2bhfcnlsfq0mqxr9a9iqwg5bwcpxfi24c6yl6krydsi";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    lv2
    gtkmm2
    boost
  ];

  preConfigure = ''
    sed -r 's,/bin/bash,${stdenv.shell},g' -i ./configure
    sed -r 's,/sbin/ldconfig,ldconfig,g' -i ./Makefile.template
  '';

  meta = {
    description = "Tools and libraries that may come in handy when writing LV2 plugins in C++";
    homepage = "http://ll-plugins.nongnu.org/hacking.html";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.michalrus ];
    platforms = lib.platforms.linux;
  };
})
