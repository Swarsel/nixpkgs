{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  tokenize-rt,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyupgrade";
  version = "3.21.2";

  src = fetchFromGitHub {
    owner = "asottile";
    repo = "pyupgrade";
    rev = "v${finalAttrs.version}";
    hash = "sha256-u4iudzPhVuAOS9cL3z6FCVpWKJZHg7UGpe9aHnN7Byc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ tokenize-rt ];
  pyproject = true;
  pythonImportsCheck = [ "pyupgrade" ];

  meta = {
    description = "Tool to automatically upgrade syntax for newer versions of the language";
    homepage = "https://github.com/asottile/pyupgrade";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lovesegfault ];
    mainProgram = "pyupgrade";
  };
})
