{
  lib,
  fetchFromGitHub,
  aiohttp,
  backoff,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyopensprinkler";
  version = "0.7.17";

  src = fetchFromGitHub {
    owner = "vinteo";
    repo = "py-opensprinkler";
    rev = version;
    hash = "sha256-5iGvC7S1DdowkT4MZCkI5toy1AKYiMITwy84VYwW/0U=";
  };

  # There are no unit tests upstream. The existing tests are unmaintained
  # integration tests that run against a docker container.
  # See <https://github.com/vinteo/py-opensprinkler/issues/4>.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    backoff
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyopensprinkler" ];

  meta = {
    description = "Python module for OpenSprinker API";
    homepage = "https://github.com/vinteo/py-opensprinkler";
    changelog = "https://github.com/vinteo/py-opensprinkler/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jfly ];
  };
}
