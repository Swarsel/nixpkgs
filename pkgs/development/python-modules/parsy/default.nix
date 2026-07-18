{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "parsy";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "python-parsy";
    repo = "parsy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EzIpKlT0Yvh0XWP6tb24tvuOe4BH8KuwJ5WCUzAM8mY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "parsy" ];

  meta = {
    description = "Easy-to-use parser combinators, for parsing in pure Python";
    homepage = "https://github.com/python-parsy/parsy";
    changelog = "https://github.com/python-parsy/parsy/blob/${finalAttrs.src.tag}/docs/history.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ milibopp ];
  };
})
