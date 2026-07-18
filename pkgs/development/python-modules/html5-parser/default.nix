{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  chardet,
  lxml,
  pkg-config,
  pkgs,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "html5-parser";
  version = "0.4.12";

  src = fetchFromGitHub {
    owner = "kovidgoyal";
    repo = "html5-parser";
    tag = "v${version}";
    hash = "sha256-0Qn+To/d3+HMx+KhhgJBEHVYPOfIeBnngBraY7r4uSs=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pkgs.libxml2 ];

  propagatedBuildInputs = [
    chardet
    lxml
  ];

  nativeCheckInputs = [
    beautifulsoup4
    pytestCheckHook
  ];

  enabledTestPaths = [ "test/*.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "html5_parser" ];

  meta = {
    description = "Fast C based HTML 5 parsing for python";
    homepage = "https://html5-parser.readthedocs.io";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
