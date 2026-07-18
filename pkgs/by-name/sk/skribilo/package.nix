{
  lib,
  stdenv,
  fetchurl,
  emacs,
  fig2dev,
  gettext,
  ghostscript,
  guile,
  guile-lib,
  guile-reader,
  imagemagick,
  lout,
  makeWrapper,
  pkg-config,
  ploticus,
  texliveSmall,
  enableEmacs ? false,
  enableLout ? stdenv.hostPlatform.isLinux,
  enablePloticus ? stdenv.hostPlatform.isLinux,
  enableTex ? true,
}:

let
  inherit (lib) optional;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "skribilo";
  version = "0.10.0";

  src = fetchurl {
    url = "mirror://savannah/skribilo/skribilo-${finalAttrs.version}.tar.gz";
    hash = "sha256-jP9I7hds7f1QMmSaNJpGlSvqUOwGcg+CnBzMopIS9Q4=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    fig2dev
    gettext
    ghostscript
    guile
    guile-lib
    guile-reader
    imagemagick
  ]
  ++ optional enableEmacs emacs
  ++ optional enableLout lout
  ++ optional enablePloticus ploticus
  ++ optional enableTex texliveSmall;

  postInstall = ''
    wrapProgram $out/bin/skribilo \
      --prefix GUILE_LOAD_PATH : "$out/${guile.siteDir}:$GUILE_LOAD_PATH" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/${guile.siteCcacheDir}:$GUILE_LOAD_COMPILED_PATH"
  '';

  meta = {
    description = "Ultimate Document Programming Framework";

    longDescription = ''
      Skribilo is a free document production tool that takes a structured
      document representation as its input and renders that document in a
      variety of output formats: HTML and Info for on-line browsing, and Lout
      and LaTeX for high-quality hard copies.

      The input document can use Skribilo's markup language to provide
      information about the document's structure, which is similar to HTML or
      LaTeX and does not require expertise. Alternatively, it can use a simpler,
      "markup-less" format that borrows from Emacs' outline mode and from other
      conventions used in emails, Usenet and text.
    '';

    homepage = "https://www.nongnu.org/skribilo/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
