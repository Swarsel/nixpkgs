{
  lib,
  stdenv,
  fetchFromGitHub,
  vdr,
}:
stdenv.mkDerivation rec {
  pname = "vdr-streamdev";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "vdr-projects";
    repo = "vdr-plugin-streamdev";
    rev = version;
    sha256 = "sha256-l+0JHjzuCx/UDbrDz+PSarG6IIwlUcPTgXUDypM4tds=";
  };

  buildInputs = [
    vdr
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "LIBDIR=/lib/vdr"
    "LOCDIR=/share/locale"
  ];

  # configure don't accept argument --prefix
  dontAddPrefix = true;
  enableParallelBuilding = true;

  meta = {
    inherit (src.meta) homepage;
    inherit (vdr.meta) platforms;
    description = "This PlugIn is a VDR implementation of the VTP (Video Transfer Protocol) Version 0.0.3 (see file PROTOCOL) and a basic HTTP Streaming Protocol";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.ck3d ];
  };
}
