{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  parameterized,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pypika";
  version = "0.50.0";

  src = fetchFromGitHub {
    owner = "kayak";
    repo = "pypika";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gjHr4tWy1kL7IxOe5QmH0S/HB+MsF/IOIQcTu3yjv6c=";
  };

  nativeCheckInputs = [
    parameterized
    unittestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pypika" ];

  meta = {
    description = "Python SQL query builder";
    homepage = "https://github.com/kayak/pypika";
    changelog = "https://github.com/kayak/pypika/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
