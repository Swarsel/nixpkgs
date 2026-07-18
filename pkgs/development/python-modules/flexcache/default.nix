{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # checks
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  # dependencies
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "flexcache";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "hgrecco";
    repo = "flexcache";
    rev = version;
    hash = "sha256-MAbTe7NxzfRPzo/Wnb5SnPJvJWf6zVeYsaw/g9OJYSE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "flexcache" ];

  meta = {
    description = "Robust and extensible package to cache on disk the result of expensive calculations";
    homepage = "https://github.com/hgrecco/flexcache";
    changelog = "https://github.com/hgrecco/flexcache/blob/${src.rev}/CHANGES";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
