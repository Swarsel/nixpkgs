{
  lib,
  fetchurl,
  djvulibre,
  fetchpatch,
  file,
  ghostscript,
  # runtime dependencies
  imagemagick,
  # libs
  librsvg,
  libtiff,
  pdftk,
  perlPackages,
  poppler-utils,
  sane-backends,
  sane-frontends,
  tesseract,
  unpaper,
  wrapGAppsHook3,
  # test dependencies
  xvfb-run,
}:

perlPackages.buildPerlPackage rec {
  pname = "gscan2pdf";
  version = "2.13.5";

  src = fetchurl {
    url = "mirror://sourceforge/gscan2pdf/gscan2pdf-${version}.tar.xz";
    hash = "sha256-DUME9nI9B2+Gj+sBPj176SXfuxDc3CMXfby/Zga31fo=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # fixes an error with utf8 file names. See https://sourceforge.net/p/gscan2pdf/bugs/400
    ./image-utf8-fix.patch
  ];

  # Required for the program to properly load its SVG assets
  postPatch = ''
    substituteInPlace bin/gscan2pdf \
      --replace-fail "/usr/share" "$out/share"
  '';

  nativeBuildInputs = [ wrapGAppsHook3 ];

  buildInputs = [
    librsvg
    sane-backends
    sane-frontends
  ]
  ++ (with perlPackages; [
    Gtk3
    Gtk3ImageView
    Gtk3SimpleList
    Cairo
    CairoGObject
    Glib
    GlibObjectIntrospection
    GooCanvas2
    GraphicsTIFF
    IPCSystemSimple
    LocaleCodes
    LocaleGettext
    PDFBuilder
    ImagePNGLibpng
    ImageSane
    SetIntSpan
    ImageMagick
    ConfigGeneral
    ListMoreUtils
    HTMLParser
    ProcProcessTable
    LogLog4perl
    TryTiny
    DataUUID
    DateCalc
    IOString
    FilesysDf
    SubOverride
  ]);

  nativeCheckInputs = [
    imagemagick
    libtiff
    djvulibre
    poppler-utils
    ghostscript
    unpaper
    pdftk

    xvfb-run
    file
    tesseract
  ]
  ++ (with perlPackages; [
    TestPod
  ]);

  checkPhase = ''
    # Skip a failing test, due to a change in ImageMagick:
    # https://sourceforge.net/p/gscan2pdf/bugs/439/
    rm t/04_Page.t

    # Skip a failing test, due to a breaking change in ImageMagick:
    # https://sourceforge.net/p/gscan2pdf/bugs/442/
    # https://github.com/ImageMagick/ImageMagick/issues/8714
    rm t/113_save_pdf_with_downsample.t

    export XDG_CACHE_HOME="$(mktemp -d)"
    xvfb-run -s '-screen 0 800x600x24' \
      make test
  '';

  postInstall = ''
    # Remove impurity
    find $out -type f -name "*.pod" -delete

    # Add runtime dependencies
    wrapProgram "$out/bin/gscan2pdf" \
      --prefix PATH : "${sane-backends}/bin" \
      --prefix PATH : "${imagemagick}/bin" \
      --prefix PATH : "${libtiff}/bin" \
      --prefix PATH : "${djvulibre}/bin" \
      --prefix PATH : "${poppler-utils}/bin" \
      --prefix PATH : "${ghostscript}/bin" \
      --prefix PATH : "${unpaper}/bin" \
      --prefix PATH : "${pdftk}/bin"
  '';

  enableParallelBuilding = true;
  installTargets = [ "install" ];

  meta = {
    description = "GUI to produce PDFs or DjVus from scanned documents";
    homepage = "https://gscan2pdf.sourceforge.net/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ euxane ];
    mainProgram = "gscan2pdf";
  };
}
