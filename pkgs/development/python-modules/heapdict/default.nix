{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "heapdict";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-hJX1ez4D2ORtXxssxiyogayjkv1cwEjcCqLhptI+zbY=";
    pname = "HeapDict";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "heapdict" ];

  meta = {
    description = "Heap with decrease-key and increase-key operations";
    homepage = "https://github.com/DanielStutzbach/heapdict";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ teh ];
  };
}
