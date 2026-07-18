{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gettext,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "setuptools-gettext";
  version = "0.1.18";

  src = fetchFromGitHub {
    owner = "breezy-team";
    repo = "setuptools-gettext";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IhlJ+g4ppHzG6n0OawvZULm9DqyDm2mjiXmc2ft+xXU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    gettext
  ];

  build-system = [ setuptools ];
  dependencies = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "setuptools_gettext" ];

  meta = {
    description = "Setuptools plugin for building mo files";
    homepage = "https://github.com/breezy-team/setuptools-gettext";
    changelog = "https://github.com/breezy-team/setuptools-gettext/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
