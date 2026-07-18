{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "lru-dict";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "amitdev";
    repo = "lru-dict";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pHjBTAXoOUyTSzzHzOBZeMFkJhzspylMhxwqXYLFOQg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==" "setuptools>="
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lru" ];

  meta = {
    description = "Fast and memory efficient LRU cache for Python";
    homepage = "https://github.com/amitdev/lru-dict";
    changelog = "https://github.com/amitdev/lru-dict/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
