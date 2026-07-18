{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  # tests
  pytest-asyncio,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "uncalled-for";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "chrisguidry";
    repo = "uncalled-for";
    tag = finalAttrs.version;
    hash = "sha256-5jFMlynYaxd83SQiZ1uPs1whWFgKP4y6s473TplH4iI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytest-timeout
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  pyproject = true;
  pythonImportsCheck = [ "uncalled_for" ];

  meta = {
    description = "Async dependency injection for Python functions";
    homepage = "https://github.com/chrisguidry/uncalled-for";
    changelog = "https://github.com/chrisguidry/uncalled-for/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ squat ];
  };
})
