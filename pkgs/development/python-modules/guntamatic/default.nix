{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "guntamatic";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "JensTimmerman";
    repo = "guntamatic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OQpbBdTxbKd2A9AWJOLmoKNmPx3ZXTWqLgwTndDWMuw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "guntamatic" ];

  meta = {
    description = "Module to get data from a Guntamatic heater e.g. BMK 20";
    homepage = "https://github.com/JensTimmerman/guntamatic";
    changelog = "https://github.com/JensTimmerman/guntamatic/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
