{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "tellcore-net";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "tellcore-net";
    tag = finalAttrs.version;
    hash = "sha256-yMNAu8iSFB2UDqJR3u2XFelpGRKzi/3HyuEbrZK6v8g=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "tellcorenet" ];

  meta = {
    description = "Python module that allows to run tellcore over TCP/IP";
    homepage = "https://github.com/home-assistant-libs/tellcore-net";
    changelog = "https://github.com/home-assistant-libs/tellcore-net/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
