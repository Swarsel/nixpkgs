{
  lib,
  fetchFromGitLab,
  imagemagick,
  inkscape,
  jq,
  stdenvNoCC,
  xcursorgen,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hackneyed";
  version = "0.9.3";

  src = fetchFromGitLab {
    owner = "Enthymeme";
    repo = "hackneyed-x11-cursors";
    rev = version;
    hash = "sha256-gq+qBYm15satH/XXK1QYDVu2L2DvZ+2aYg/wDqncwmA=";
  };

  postPatch = ''
    patchShebangs *.sh
  '';

  nativeBuildInputs = [
    imagemagick
    inkscape
    jq
    xcursorgen
  ];

  makeFlags = [
    "INKSCAPE=inkscape"
    "INSTALL=install"
    "JQ=jq"
    "PREFIX=$(out)"
    "VERBOSE=1"
    "XCURSORGEN=xcursorgen"
  ];

  buildFlags = [
    "theme"
    "theme.left"
  ];

  enableParallelBuilding = true;

  # The Makefile declares a dependency on the value of $(INKSCAPE) for some reason;
  # it's unnecessary for building though.
  prePatch = ''
    substituteInPlace GNUmakefile \
        --replace 'inkscape-version: $(INKSCAPE)' 'inkscape-version:'
  '';

  meta = {
    description = "Scalable cursor theme that resembles Windows 3.x/NT 3.x cursors";
    homepage = "https://gitlab.com/Enthymeme/hackneyed-x11-cursors";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
    platforms = lib.platforms.all;
  };
}
