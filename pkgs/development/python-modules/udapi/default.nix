{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  colorama,
  pytestCheckHook,
  setuptools,
  termcolor,
}:

buildPythonPackage (finalAttrs: {
  pname = "udapi";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "udapi";
    repo = "udapi-python";
    tag = finalAttrs.version;
    hash = "sha256-0h4nfd3QHdZNiT0VFBs6xJ/lpiNPzcJQmV60KoH0Nv0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    colorama
    termcolor
  ];

  pyproject = true;
  pythonImportsCheck = [ "udapi" ];

  meta = {
    description = "Python framework for processing Universal Dependencies data";
    homepage = "https://github.com/udapi/udapi-python";
    changelog = "https://github.com/udapi/udapi-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      Stebalien
    ];
  };
})
