{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "standard-mailcap";
  version = "3.13.0";

  src = fetchFromGitHub {
    owner = "youknowone";
    repo = "python-deadlib";
    tag = "v${version}";
    hash = "sha256-9mtQi5ufxP6xRonTrFC3oWFpWLbJraAmdQYozP3evgc=";
    sparseCheckout = [ "mailcap" ];
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  disabled = pythonOlder "3.13";
  pyproject = true;
  pythonImportsCheck = [ "mailcap" ];
  sourceRoot = "${src.name}/mailcap";

  meta = {
    description = "Standard library mailcap redistribution";
    homepage = "https://github.com/youknowone/python-deadlib";
    license = lib.licenses.psfl;
    maintainers = [ lib.maintainers.lucc ];
  };
}
