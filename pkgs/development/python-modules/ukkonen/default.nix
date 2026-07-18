{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ukkonen";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "asottile";
    repo = "ukkonen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vXyOLAiY92Df7g57quiSnOz8yhaIsm8MTB6Fbiv6axQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cffi
    setuptools
  ];

  dependencies = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "ukkonen" ];

  meta = {
    description = "Python implementation of bounded Levenshtein distance (Ukkonen)";
    homepage = "https://github.com/asottile/ukkonen";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
