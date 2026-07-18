{
  lib,
  buildPythonPackage,
  fetchPypi,
  pymorphy2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "yargy";
  version = "0.16.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-yRfu+zKkDCPEa2yojWiScHLdAKuU6Q/V3GqwpitZtZM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pymorphy2 ];
  enabledTestPaths = [ "tests" ];
  pyproject = true;
  pythonImportsCheck = [ "yargy" ];

  meta = {
    description = "Rule-based facts extraction for Russian language";
    homepage = "https://github.com/natasha/yargy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ npatsakula ];
  };
})
