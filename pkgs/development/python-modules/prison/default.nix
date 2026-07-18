{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "prison";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "betodealmeida";
    repo = "python-rison";
    rev = version;
    hash = "sha256-qor40vUQeTdlO3vwug3GGNX5vkNaF0H7EWlRdsY4bvc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;

  meta = {
    description = "Rison encoder/decoder";
    homepage = "https://github.com/betodealmeida/python-rison";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
