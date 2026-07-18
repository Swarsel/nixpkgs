{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cached-property,
  loguru,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "whoosh-reloaded";
  version = "2.7.5";

  src = fetchFromGitHub {
    owner = "Sygil-Dev";
    repo = "whoosh-reloaded";
    tag = "v${version}";
    hash = "sha256-frM8tw298Yz3u3rLK4CxWUXL6ymCSwYyYhXP/EdyjtQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    cached-property
    loguru
  ];

  pyproject = true;
  pythonImportsCheck = [ "whoosh" ];

  meta = {
    description = "Fast, featureful full-text indexing and searching library implemented in pure Python";
    homepage = "https://github.com/Sygil-Dev/whoosh-reloaded";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
