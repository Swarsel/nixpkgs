{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  loguru,
  mbstrdecoder,
  pytestCheckHook,
  setuptools-scm,
  tcolorpy,
  termcolor,
  typepy,
}:

buildPythonPackage rec {
  pname = "dataproperty";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "thombashi";
    repo = "dataproperty";
    tag = "v${version}";
    hash = "sha256-PLXF9g0VIkmsRLl5+KvXcbbwVwaJSYjWB7l8xz1mPZM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    termcolor
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    mbstrdecoder
    typepy
    tcolorpy
  ]
  ++ typepy.optional-dependencies.datetime;

  optional-dependencies = {
    logging = [ loguru ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dataproperty" ];

  meta = {
    description = "Library for extracting properties from data";
    homepage = "https://github.com/thombashi/DataProperty";
    changelog = "https://github.com/thombashi/DataProperty/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
