{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fontfeatures,
  fonttools,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:
buildPythonPackage (finalAttrs: {
  pname = "ufo-extractor";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "robotools";
    repo = "extractor";
    tag = finalAttrs.version;
    hash = "sha256-SzNNRC2UxjyypgiM0iIicfemC67D6GW2jszNak8yCSM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fonttools
    fontfeatures
  ];

  pyproject = true;
  pythonImportsCheck = [ "extractor" ];

  meta = {
    description = "Tools for extracting data from font binaries into UFO objects";
    homepage = "https://github.com/robotools/extractor";
    changelog = "https://github.com/robotools/extractor/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      qb114514
    ];
  };
})
