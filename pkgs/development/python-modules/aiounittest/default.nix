{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  wrapt,
}:

buildPythonPackage rec {
  pname = "aiounittest";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "kwarunek";
    repo = "aiounittest";
    tag = version;
    hash = "sha256-zX3KpDw7AaEwOLkiHX/ZD+rSMeN7qi9hOVAmVH6Jxgg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ wrapt ];
  # https://github.com/kwarunek/aiounittest/issues/28
  disabled = pythonAtLeast "3.14";
  pyproject = true;
  pythonImportsCheck = [ "aiounittest" ];

  meta = {
    description = "Test asyncio code more easily";
    homepage = "https://github.com/kwarunek/aiounittest";
    changelog = "https://github.com/kwarunek/aiounittest/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
