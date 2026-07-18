{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  distro,
  filelock,
  pytest-mock,
  pytestCheckHook,
  requests,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "iterative-telemtry";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "iterative";
    repo = "telemetry-python";
    tag = version;
    hash = "sha256-+l9JH9MbN+Pai3MIcKZJObzoPGhQipfMd7T8v4SoSws=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    requests
    appdirs
    filelock
    distro
  ];

  pyproject = true;
  pythonImportsCheck = [ "iterative_telemetry" ];

  meta = {
    description = "Common library to send usage telemetry";
    homepage = "https://github.com/iterative/iterative-telemetry";
    changelog = "https://github.com/iterative/iterative-telemetry/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
  };
}
