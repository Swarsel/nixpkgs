{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  pillow,
  reportlab,
}:
buildPythonPackage rec {
  pname = "hocr-tools";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "ocropus";
    repo = "hocr-tools";
    rev = "v${version}";
    sha256 = "14f9hkp7pr677085w8iidwd0la9cjzy3pyj3rdg9b03nz9pc0w6p";
  };

  propagatedBuildInputs = [
    pillow
    lxml
    reportlab
  ];

  # hocr-tools uses a test framework that requires internet access
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Tools for manipulating and evaluating the hOCR format for representing multi-lingual OCR results by embedding them into HTML";
    homepage = "https://github.com/ocropus/hocr-tools";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
