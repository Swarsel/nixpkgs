{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chardet,
  cssselect,
  lxml,
  lxml-html-clean,
  poetry-core,
  pytestCheckHook,
  timeout-decorator,
}:

buildPythonPackage rec {
  pname = "readability-lxml";
  version = "0.8.4.1";

  src = fetchFromGitHub {
    owner = "buriy";
    repo = "python-readability";
    rev = "${version}";
    hash = "sha256-tL0OnvCrbrpBvcy+6RJ+u/BDdra+MnVT51DSAeYxJbc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    timeout-decorator
  ];

  build-system = [ poetry-core ];

  dependencies = [
    chardet
    cssselect
    lxml
    lxml-html-clean
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "chardet"
    "lxml"
  ];

  meta = {
    description = "Fast python port of arc90's readability tool";
    homepage = "https://github.com/buriy/python-readability";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ siraben ];
  };
}
