{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyintesishome";
  version = "1.8.8";

  src = fetchFromGitHub {
    owner = "jnimmo";
    repo = "pyIntesisHome";
    tag = finalAttrs.version;
    hash = "sha256-wB4rrguafKEzAVYRTKQQTG4Z48obWrigLHbeGdoNQrQ=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyintesishome" ];

  meta = {
    description = "Python interface for IntesisHome devices";
    homepage = "https://github.com/jnimmo/pyIntesisHome";
    changelog = "https://github.com/jnimmo/pyIntesisHome/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
