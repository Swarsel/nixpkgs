{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  importlib-metadata,
  importlib-resources,
  nix-update-script,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "cmudict";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "prosegrinder";
    repo = "python-cmudict";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pOqzezrDlwlVsvBHreHmLKxYKDxllZNs0TgLwxBhy58=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ poetry-core ];

  dependencies = [
    importlib-metadata
    importlib-resources
  ];

  pyproject = true;
  pythonImportsCheck = [ "cmudict" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Python wrapper package for The CMU Pronouncing Dictionary data files";
    homepage = "https://github.com/prosegrinder/python-cmudict";
    changelog = "https://github.com/prosegrinder/python-cmudict/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sandarukasa ];
  };
})
