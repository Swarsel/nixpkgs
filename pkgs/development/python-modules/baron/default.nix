{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  pytestCheckHook,
  rply,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "baron";
  version = "0.10.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-r4Iq1E1OtCXIUW30I5rE/bqf2zmO935JJM18m0BFvC8=";
  };

  doCheck = isPy3k;
  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ rply ];
  pyproject = true;
  pythonImportsCheck = [ "baron" ];

  meta = {
    description = "Abstraction on top of baron, a FST for python to make writing refactoring code a realistic task";
    homepage = "https://github.com/PyCQA/baron";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
})
