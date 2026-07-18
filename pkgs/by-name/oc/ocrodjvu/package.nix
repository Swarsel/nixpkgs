{
  lib,
  fetchFromGitHub,
  cuneiform,
  djvulibre,
  docbook-xsl-ns,
  glibcLocales,
  gocr,
  libxml2,
  libxml2Python,
  libxslt,
  ocrad,
  pkg-config,
  python3Packages,
  tesseract5,
  withCuneiform ? false,
  withGocr ? false,
  withOcrad ? false,
}:

python3Packages.buildPythonApplication rec {
  pname = "ocrodjvu";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "FriedrichFroebel";
    repo = "ocrodjvu";
    tag = version;
    hash = "sha256-/TPo8YCE8JKKKBBeV12ilgTNDmuklwfy0TPI/7dBiOs=";
  };

  propagatedBuildInputs = [
  ]
  ++ lib.optional withCuneiform cuneiform
  ++ lib.optional withGocr gocr
  ++ lib.optional withOcrad ocrad;

  nativeCheckInputs = [
    python3Packages.unittestCheckHook
    python3Packages.pillow
    djvulibre
    glibcLocales
    libxml2
    libxml2Python
    tesseract5
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    lxml
    python-djvulibre
    pyicu
    html5lib
  ];

  pyproject = true;

  unittestFlagsArray = [
    "tests"
    "-v"
  ];

  meta = {
    description = "Wrapper for OCR systems that allows you to perform OCR on DjVu files";
    homepage = "https://github.com/FriedrichFroebel/ocrodjvu";
    changelog = "https://github.com/FriedrichFroebel/ocrodjvu/blob/${version}/doc/changelog";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dansbandit ];
    platforms = lib.platforms.linux;
    mainProgram = "ocrodjvu";
  };
}
