{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyaqvify";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "astrandb";
    repo = "pyaqvify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZSSr7cWDvPxVq8YIqCPpE+nxrk/UHuNGZ/muyiGyp/c=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyaqvify" ];

  meta = {
    description = "Python async library for Aqvify integration with Home Assistant";
    homepage = "https://github.com/astrandb/pyaqvify";
    changelog = "https://github.com/astrandb/pyaqvify/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
