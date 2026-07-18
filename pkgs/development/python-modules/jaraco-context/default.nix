{
  lib,
  fetchFromGitHub,
  backports-tarfile,
  buildPythonPackage,
  pythonOlder,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-context";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.context";
    tag = "v${version}";
    hash = "sha256-2UYG1xXnH1kjYNvB6EKJPRZJ1Zd0yYhTDBTdrNFN1p4=";
  };

  postPatch = ''
    sed -i "/coherent.licensed/d" pyproject.toml
  '';

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools-scm ];
  dependencies = lib.optionals (pythonOlder "3.12") [ backports-tarfile ];
  pyproject = true;
  pythonImportsCheck = [ "jaraco.context" ];
  pythonNamespaces = [ "jaraco" ];

  meta = {
    description = "Python module for context management";
    homepage = "https://github.com/jaraco/jaraco.context";
    changelog = "https://github.com/jaraco/jaraco.context/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
