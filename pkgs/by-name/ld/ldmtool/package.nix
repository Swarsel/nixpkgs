{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  docbook_xsl,
  gobject-introspection,
  gtk-doc,
  json-glib,
  libtool,
  libuuid,
  libxslt,
  lvm2,
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ldmtool";
  version = "0.2.5-unstable-2025-02-06";

  src = fetchFromGitHub {
    owner = "mdbooth";
    repo = "libldm";
    rev = "1eafb653ac6347a9d4281848c8295f9daffb1613";
    hash = "sha256-Vd+3FnM+U5y2FxuslEsEzgZEx+5AQWuTjUVRnoFhm3I=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    gobject-introspection
  ];

  buildInputs = [
    gtk-doc
    lvm2
    libxslt.bin
    libtool
    readline
    json-glib
    libuuid
  ];

  preConfigure = ''
    sed -i docs/reference/ldmtool/Makefile.am \
      -e 's|-nonet http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|--nonet ${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl|g'
  '';

  configureScript = "sh autogen.sh";

  meta = {
    description = "Tool and library for managing Microsoft Windows Dynamic Disks";
    homepage = "https://github.com/mdbooth/libldm";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ jensbin ];
    platforms = lib.platforms.linux;
    mainProgram = "ldmtool";
  };
})
