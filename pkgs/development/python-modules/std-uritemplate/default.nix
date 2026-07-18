{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "std-uritemplate";
  version = "2.0.11";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-afqeUkc41RG7S5Sz4jk8oFJKrRGOVJJZxU2zZ+BdmFI=";
    pname = "std_uritemplate";
  };

  # Module doesn't have unittest, only functional tests
  doCheck = false;
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "stduritemplate" ];

  meta = {
    description = "Std-uritemplate implementation for Python";
    homepage = "https://github.com/std-uritemplate/std-uritemplate";
    changelog = "https://github.com/std-uritemplate/std-uritemplate/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
