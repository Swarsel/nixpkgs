{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fonttools,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "arabic-reshaper";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "mpcabd";
    repo = "python-arabic-reshaper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6i/YcYod341bg9tThZRwvaFRbtU/LxCeirq0yzmMuBI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ hatchling ];

  optional-dependencies = {
    with-fonttools = [ fonttools ];
  };

  pyproject = true;
  pythonImportsCheck = [ "arabic_reshaper" ];

  meta = {
    description = "Reconstruct Arabic sentences to be used in applications that don't support Arabic";
    homepage = "https://github.com/mpcabd/python-arabic-reshaper";
    changelog = "https://github.com/mpcabd/python-arabic-reshaper/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
  };
})
