{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  libxft,
  pkg-config,
}:

let
  version = "1.40";
in
stdenv.mkDerivation {
  inherit version;
  pname = "windowlab";

  src = fetchurl {
    url = "http://nickgravgaard.com/windowlab/windowlab-${version}.tar";
    sha256 = "1fx4jwq4s98p2wpvawsiww7d6568bpjgcjpks61dzfj8p2j32s4d";
  };

  postPatch = ''
    mv Makefile Makefile.orig
    echo \
       "
        DEFINES += -DXFT
        EXTRA_INC += $(pkg-config --cflags xft)
        EXTRA_LIBS += $(pkg-config --libs xft)
       " > Makefile
    sed "s|/usr/local|$out|g" Makefile.orig >> Makefile
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxext
    libxft
  ];

  meta = {
    description = "Small and simple stacking window manager";
    homepage = "http://nickgravgaard.com/windowlab/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "windowlab";
  };
}
