{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "case-converter";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "chrisdoherty4";
    repo = "python-case-converter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PS/9Ndl3oD9zimEf819dNoSAeNJPndVjT+dkfW7FIJs=";
  };

  doCheck = true;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "caseconverter" ];

  meta = {
    description = "Case conversion library for Python";
    homepage = "https://github.com/chrisdoherty4/python-case-converter";
    changelog = "https://github.com/chrisdoherty4/python-case-converter/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
