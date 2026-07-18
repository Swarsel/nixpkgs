{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "rocketchat-api";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "jadolg";
    repo = "rocketchat_API";
    tag = version;
    hash = "sha256-s+RyHzuWI5pVshTG/DsgtC9+lpexTMkPJYNpNrI7Jkc=";
  };

  # requires running a Rocket.Chat server
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "rocketchat_API"
    "rocketchat_API.APIExceptions"
    "rocketchat_API.APISections"
  ];

  meta = {
    description = "Python API wrapper for Rocket.Chat";
    homepage = "https://github.com/jadolg/rocketchat_API";
    changelog = "https://github.com/jadolg/rocketchat_API/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
