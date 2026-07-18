{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "pynordpool";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "gjohansson-ST";
    repo = "pynordpool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HDbYrwQ4v5cqej5aUat0gVzaRpJz5jaFHjWUC98gacg=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pynordpool" ];

  meta = {
    description = "Python api for Nordpool";
    homepage = "https://github.com/gjohansson-ST/pynordpool";
    changelog = "https://github.com/gjohansson-ST/pynordpool/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
