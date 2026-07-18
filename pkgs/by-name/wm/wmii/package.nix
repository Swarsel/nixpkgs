{
  lib,
  stdenv,
  fetchFromGitHub,
  dash,
  libixp,
  libx11,
  libxext,
  libxft,
  libxinerama,
  libxrandr,
  libxrender,
  pkg-config,
  txt2tags,
  unzip,
  which,
}:

stdenv.mkDerivation {
  pname = "wmii";
  version = "0-unstable-2023-09-30";

  src = fetchFromGitHub {
    owner = "0intro";
    repo = "wmii";
    rev = "26848c93457606b350f57d6d313112a745a0cf3d";
    hash = "sha256-5l2aYAoThbA0Aq8M2vPTzaocQO1AvrnWqgXhmBLADVk=";
  };

  patches = [
    # the python alternative wmiirc was not building due to errors with pyxp
    # this patch disables building it altogether
    ./001-disable-python2-build.patch
  ];

  # for dlopen-ing
  postPatch = ''
    substituteInPlace lib/libstuff/x11/xft.c --replace "libXft.so" "$(pkg-config --variable=libdir xft)/libXft.so.2"
    substituteInPlace cmd/wmii.sh.sh --replace "\$(which which)" "${which}/bin/which"
  '';

  nativeBuildInputs = [
    pkg-config
    unzip
  ];

  buildInputs = [
    dash
    libx11
    libxext
    libxft
    libxinerama
    libxrandr
    libxrender
    libixp
    txt2tags
    which
  ];

  postConfigure = ''
    for file in $(grep -lr '#!.*sh'); do
      sed -i 's|#!.*sh|#!${dash}/bin/dash|' $file
    done

    cat <<EOF >> config.mk
    PREFIX = $out
    LIBIXP = ${libixp}/lib/libixp.a
    BINSH = ${dash}/bin/dash
    EOF
  '';

  meta = {
    description = "Small, scriptable window manager, with a 9P filesystem interface and an acme-like layout";
    homepage = "https://github.com/0intro/wmii";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kovirobi ];
    platforms = with lib.platforms; linux;
  };
}
