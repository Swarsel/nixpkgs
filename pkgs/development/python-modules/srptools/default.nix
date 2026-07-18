{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "srptools";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-f6QzclahVC6PW7S+0Z4dmuqY/l/5uvdmkzQqHdasfJY=";
  };

  propagatedBuildInputs = [ six ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "srptools" ];

  meta = {
    description = "Module to implement Secure Remote Password (SRP) authentication";
    homepage = "https://github.com/idlesign/srptools";
    changelog = "https://github.com/idlesign/srptools/blob/v${finalAttrs.version}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "srptools";
  };
})
