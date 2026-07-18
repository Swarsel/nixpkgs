{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  paho-mqtt,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyephember2";
  version = "2";

  src = fetchFromGitHub {
    owner = "roberty99";
    repo = "pyephember2";
    tag = "Release${version}";
    hash = "sha256-BxDXjrXPx6UNWo7mGLzbIGtenE0B10x39iCUCzGFAr0=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    paho-mqtt
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyephember2" ];

  meta = {
    description = "Python library to work with ember from EPH Controls";
    homepage = "https://github.com/ttroy50/pyephember";
    changelog = "https://github.com/roberty99/pyephember2/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
