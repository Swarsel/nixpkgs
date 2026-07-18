{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "ppf-datamatrix";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "adrianschlatter";
    repo = "ppf.datamatrix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g6KTUUYDXUlFmV0Rg3Mp23huAb+j+LTWrvY8wuYB90g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "ppf.datamatrix" ];

  meta = {
    description = "Pure-python package to generate data matrix codes";
    homepage = "https://github.com/adrianschlatter/ppf.datamatrix";
    changelog = "https://github.com/adrianschlatter/ppf.datamatrix/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
