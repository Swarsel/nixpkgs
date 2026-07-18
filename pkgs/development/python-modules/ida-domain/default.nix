{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  graphviz,
  idapro,
  nix-update-script,
  packaging,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  typing-extensions,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "ida-domain";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "HexRaysSA";
    repo = "ida-domain";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oa3VQgWDEr4tPQ166EugfS7QrW1DlRb/hwypwKP+Xv4=";
  };

  # Requires IDE to be installed
  doCheck = false;

  nativeCheckInputs = [
    graphviz
    pytest-cov-stub
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    idapro
    packaging
    typing-extensions
  ];

  pyproject = true;
  # pythonImportsCheck = [ "ida_domain" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python interface for IDA Pro reverse engineering platform";
    homepage = "https://github.com/HexRaysSA/ida-domain";
    changelog = "https://github.com/HexRaysSA/ida-domain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
