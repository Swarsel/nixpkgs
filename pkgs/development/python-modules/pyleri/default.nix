{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyleri";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "cesbit";
    repo = "pyleri";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EmdQdUKFkt3sERU0Q4JOdoiFIvtRIRIl4V4BTId7Ngo=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyleri" ];

  meta = {
    description = "Module to parse SiriDB";
    homepage = "https://github.com/cesbit/pyleri";
    changelog = "https://github.com/cesbit/pyleri/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
