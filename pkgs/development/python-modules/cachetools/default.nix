{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cachetools";
  version = "6.2.4";

  src = fetchFromGitHub {
    owner = "tkem";
    repo = "cachetools";
    tag = "v${version}";
    hash = "sha256-LlDyrjiRYCD9btDl5NA0Seb3jk3hlpNhwu0jAQp9YZE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cachetools" ];

  meta = {
    description = "Extensible memoizing collections and decorators";
    homepage = "https://github.com/tkem/cachetools";
    changelog = "https://github.com/tkem/cachetools/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
