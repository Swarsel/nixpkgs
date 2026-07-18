{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "goodwe";
  version = "0.4.10";

  src = fetchFromGitHub {
    owner = "marcelblijleven";
    repo = "goodwe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2wnfc+W1lhUgvWa1iwHxJu4WGZHaXvmxgtBAkTJHJ3E=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "goodwe" ];

  meta = {
    description = "Python library for connecting to GoodWe inverter";
    homepage = "https://github.com/marcelblijleven/goodwe";
    changelog = "https://github.com/marcelblijleven/goodwe/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
