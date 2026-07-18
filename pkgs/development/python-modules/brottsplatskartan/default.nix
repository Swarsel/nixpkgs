{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "brottsplatskartan";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "chrillux";
    repo = "brottsplatskartan";
    tag = finalAttrs.version;
    hash = "sha256-Sc8g8Pqc1ddDlkuAhSpfP4rByGPM+SGkKYHfDZmtPB4=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "brottsplatskartan" ];

  meta = {
    description = "Python API wrapper for brottsplatskartan.se";
    homepage = "https://github.com/chrillux/brottsplatskartan";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
