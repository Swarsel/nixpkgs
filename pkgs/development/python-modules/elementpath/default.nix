{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "elementpath";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "sissaschool";
    repo = "elementpath";
    tag = "v${version}";
    hash = "sha256-Ngvoq8BugTH8r187S+nUhNX/NRVhhBDX+eVc/zvq08g=";
  };

  # avoid circular dependency with xmlschema which directly depends on this
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "elementpath" ];

  meta = {
    description = "XPath 1.0/2.0 parsers and selectors for ElementTree and lxml";
    homepage = "https://github.com/sissaschool/elementpath";
    changelog = "https://github.com/sissaschool/elementpath/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
