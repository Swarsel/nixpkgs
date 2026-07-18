{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "paradict";
  version = "0.0.16";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2QnRIr9HAopFM06yKA0eG8tAH9qJmGr0LDn9L6353k0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "paradict" ];

  meta = {
    description = "Streamable multi-format serialization";
    homepage = "https://pypi.org/project/paradict/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
