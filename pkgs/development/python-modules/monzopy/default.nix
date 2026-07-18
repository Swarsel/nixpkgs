{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "monzopy";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "JakeMartin-ICL";
    repo = "monzopy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LMg3hCaNa9LF3pZEQ/uQgt81V6qKmOwZnKHdsI8MHLY=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "monzopy" ];

  meta = {
    description = "Module to work with the Monzo API";
    homepage = "https://github.com/JakeMartin-ICL/monzopy";
    changelog = "https://github.com/JakeMartin-ICL/monzopy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
