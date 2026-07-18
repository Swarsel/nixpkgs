{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  ruamel-yaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "gawd";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "sgl-umons";
    repo = "gawd";
    tag = finalAttrs.version;
    hash = "sha256-DCcU7vO5VApRsO+ljVs827TrHIfe3R+1/2wgBEcp1+c=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [ ruamel-yaml ];
  pyproject = true;
  pythonImportsCheck = [ "gawd" ];

  meta = {
    description = "Python library and command-line tool for computing syntactic differences between two GitHub Actions workflow files";
    homepage = "https://github.com/sgl-umons/gawd";
    changelog = "https://github.com/sgl-umons/gawd/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "gawd";
  };
})
