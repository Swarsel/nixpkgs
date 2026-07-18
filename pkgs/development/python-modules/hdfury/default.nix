{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "hdfury";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "glenndehaan";
    repo = "python-hdfury";
    tag = finalAttrs.version;
    hash = "sha256-ndJpxFebSsfXQ1aUe20Ajbgks3gA3KXo8kY5FaJ/BW0=";
  };

  # Module no tests
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "hdfury" ];

  meta = {
    description = "Python client for HDFury devices";
    homepage = "https://github.com/glenndehaan/python-hdfury";
    changelog = "https://github.com/glenndehaan/python-hdfury/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
