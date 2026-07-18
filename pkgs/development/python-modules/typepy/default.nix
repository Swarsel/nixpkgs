{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mbstrdecoder,
  packaging,
  pytestCheckHook,
  python-dateutil,
  pytz,
  setuptools-scm,
  tcolorpy,
}:

buildPythonPackage rec {
  pname = "typepy";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "thombashi";
    repo = "typepy";
    tag = "v${version}";
    hash = "sha256-lgwXoEtv2nBRKiWQH5bDrAIfikKN3cOqcHLEdnSAMpc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    tcolorpy
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools-scm ];
  dependencies = [ mbstrdecoder ];

  optional-dependencies = {
    datetime = [
      python-dateutil
      pytz
      packaging
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "typepy" ];

  meta = {
    description = "Library for variable type checker/validator/converter at a run time";
    homepage = "https://github.com/thombashi/typepy";
    changelog = "https://github.com/thombashi/typepy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
