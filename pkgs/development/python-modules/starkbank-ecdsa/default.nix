{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "starkbank-ecdsa";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "starkbank";
    repo = "ecdsa-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5yF2tVCgHJX++NncWiYfLE0P98Sxy91VN3qgc8PSLOI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd tests
  '';

  build-system = [ setuptools ];

  enabledTestPaths = [
    "*.py"
  ];

  pyproject = true;

  pytestFlags = [
    "-v"
  ];

  pythonImportsCheck = [ "ellipticcurve" ];

  meta = {
    description = "Python ECDSA library";
    homepage = "https://github.com/starkbank/ecdsa-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
