{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchDebianPatch,
  glib,
  gtk3,
  gtksourceview3,
  gtkspell3,
  intltool,
  pkg-config,
  poppler,
  texlive,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gummi";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "alexandervdm";
    repo = "gummi";
    rev = finalAttrs.version;
    sha256 = "sha256-71n71KjLmICp4gznd27NlbyA3kayje3hYk/cwkOXEO0=";
  };

  patches = [
    (fetchDebianPatch {
      pname = "gummi";
      version = "0.8.3+really0.8.3";
      debianRevision = "6";
      hash = "sha256-YNOVgZHJIVy7y60FOZRI8N8qxoOkUsResLo0PNZ0dkY=";
      patch = "0002-build-with-gcc-15.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    intltool
    autoreconfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtksourceview3
    gtk3
    gtkspell3
    poppler
    texlive.bin.core # needed for synctex
  ];

  postInstall = ''
    install -Dpm644 COPYING $out/share/licenses/$name/COPYING
  '';

  meta = {
    description = "Simple LaTex editor for GTK users";
    homepage = "https://gummi.app";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
    platforms = with lib.platforms; linux;
    mainProgram = "gummi";
  };
})
