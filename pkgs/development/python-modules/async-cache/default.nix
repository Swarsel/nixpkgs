{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "async-cache";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "iamsinghrajat";
    repo = "async-cache";
    tag = finalAttrs.version;
    hash = "sha256-3SPepAlXJxufTgNqwxh/c2jhL/j9/omqOZElHhDiIIw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cache" ];

  meta = {
    description = "Caching solution for asyncio";
    homepage = "https://github.com/iamsinghrajat/async-cache";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.lukegb ];
  };
})
