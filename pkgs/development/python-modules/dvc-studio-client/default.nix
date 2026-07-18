{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dulwich,
  gitpython,
  requests,
  setuptools-scm,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "dvc-studio-client";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "iterative";
    repo = "dvc-studio-client";
    tag = version;
    hash = "sha256-Zc6DQ/memnEwxHkSMPi1/fLBgvinqaMpWSOBfAI4sUk=";
  };

  # Tests try to access network
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    dulwich
    gitpython
    requests
    voluptuous
  ];

  pyproject = true;
  pythonImportsCheck = [ "dvc_studio_client" ];

  meta = {
    description = "Library to post data from DVC/DVCLive to Iterative Studio";
    homepage = "https://github.com/iterative/dvc-studio-client";
    changelog = "https://github.com/iterative/dvc-studio-client/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
  };
}
