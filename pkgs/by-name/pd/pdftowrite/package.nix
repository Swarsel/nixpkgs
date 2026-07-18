{
  lib,
  fetchFromGitHub,
  ghostscript,
  # shared
  gzip,
  imagemagick,
  inkscape,
  librsvg,
  libxml2,
  libxslt,
  makeWrapper,
  nix-update-script,
  pdftk,
  # pdftowrite
  poppler-utils,
  python3Packages,
  versionCheckHook,
  # writetopdf
  wkhtmltopdf,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pdftowrite";
  version = "2021.05.03";

  src = fetchFromGitHub {
    owner = "apebl";
    repo = "pdftowrite";
    tag = finalAttrs.version;
    hash = "sha256-IFX9K74tfGKyMtqlc/RsV00baZEzE3HcPAGfrmTHnDQ=";
  };

  patches = [
    # fix inkscape flag (see https://gitlab.com/inkscape/inkscape/-/issues/4536)
    ./inkscape-unknown-option-pdf-page.patch
  ];

  nativeCheckInputs = [ versionCheckHook ];

  postInstall =
    let
      pdftowritePath = lib.makeBinPath [
        # shared
        gzip
        # pdftowrite
        poppler-utils
        inkscape
        ghostscript
        imagemagick
        libxml2
        libxslt
      ];
      writetopdfPath = lib.makeBinPath [
        # shared
        gzip
        # writetopdf
        wkhtmltopdf
        pdftk
        librsvg
      ];
    in
    # `SELF_CALL=xxx` prevents inkscape shananigans (see https://gitlab.com/inkscape/inkscape/-/issues/4716)
    ''
      wrapProgram $out/bin/pdftowrite --prefix PATH : ${pdftowritePath} \
        --set SELF_CALL=xxx
      wrapProgram $out/bin/writetopdf --prefix PATH : ${writetopdfPath}
    '';

  build-system = [
    python3Packages.setuptools
    python3Packages.setuptools-scm
    makeWrapper
  ];

  dependencies = [
    python3Packages.shortuuid
    python3Packages.picosvg
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Utility that converts PDF to Stylus Labs Write documents, and vice versa";
    homepage = "https://github.com/apebl/pdftowrite";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ henrispriet ];
    platforms = lib.platforms.linux;
  };
})
