{
  lib,
  buildPythonPackage,
  cssselect2,
  fetchPypi,
  lxml,
  pillow,
  pytestCheckHook,
  reportlab,
  tinycss2,
}:

buildPythonPackage rec {
  pname = "svglib";
  version = "1.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Oudl06lAnuYMD7TSTC3raoBheqknBU9bzX/JjwaV5Yc=";
  };

  propagatedBuildInputs = [
    cssselect2
    lxml
    pillow
    reportlab
    tinycss2
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # Ignore tests that require network access (TestWikipediaFlags and TestW3CSVG), and tests that
    # require files missing in the 1.0.0 PyPI release (TestOtherFiles).
    "TestWikipediaFlags"
    "TestW3CSVG"
    "TestOtherFiles"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "svglib.svglib" ];

  meta = {
    description = "Pure-Python library for reading and converting SVG";
    homepage = "https://github.com/deeplook/svglib";
    changelog = "https://github.com/deeplook/svglib/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
    mainProgram = "svg2pdf";
  };
}
