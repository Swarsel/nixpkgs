{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ansimarkup";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "gvalkov";
    repo = "python-ansimarkup";
    tag = "v${version}";
    hash = "sha256-+kZt8tv09RHrMRZtvJPBBiFaeCksXyrlHqIabPrXYDY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ colorama ];
  pyproject = true;
  pythonImportsCheck = [ "ansimarkup" ];

  meta = {
    description = "XML-like markup for producing colored terminal text";
    homepage = "https://github.com/gvalkov/python-ansimarkup";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
