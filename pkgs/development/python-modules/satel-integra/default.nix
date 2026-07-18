{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "satel-integra";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "c-soft";
    repo = "satel_integra";
    tag = version;
    hash = "sha256-lNlre+0mOmIjrmYsAqt0QERERsXzKi0wRfbs1c//f/c=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cryptography
  ];

  pyproject = true;
  pythonImportsCheck = [ "satel_integra" ];

  meta = {
    description = "Communication library and basic testing tool for Satel Integra alarm system";
    homepage = "https://github.com/c-soft/satel_integra";
    changelog = "https://github.com/c-soft/satel_integra/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
