{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  pytestCheckHook,
  python-dateutil,
  requests,
  requests-mock,
  setuptools,
  sphinx-rtd-theme,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-tes";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "ohsu-comp-bio";
    repo = "py-tes";
    tag = finalAttrs.version;
    hash = "sha256-/xgycSDFp17rPzC6ICf4e+vrIKWYPftDngx/u1/KHWk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    python-dateutil
    requests
    sphinx-rtd-theme
  ];

  disabledTestPaths = [
    # Tests require running funnel
    "tests/integration"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tes" ];

  meta = {
    description = "Python SDK for the GA4GH Task Execution API";
    homepage = "https://github.com/ohsu-comp-bio/py-tes";
    changelog = "https://github.com/ohsu-comp-bio/py-tes/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
