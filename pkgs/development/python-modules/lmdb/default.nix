{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  lmdb,
  patch-ng,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "lmdb";
  version = "2.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-sgG0FvfWzqm9L5dyd6X1HW5SpDTW7FEaizSZDfKxqcU=";
  };

  nativeBuildInputs = [ cffi ];
  buildInputs = [ lmdb ];
  env.LMDB_FORCE_SYSTEM = 1;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ patch-ng ];
  pyproject = true;
  pythonImportsCheck = [ "lmdb" ];

  meta = {
    description = "Universal Python binding for the LMDB 'Lightning' Database";
    homepage = "https://github.com/dw/py-lmdb";
    changelog = "https://github.com/jnwatson/py-lmdb/blob/py-lmdb_${finalAttrs.version}/ChangeLog";
    license = lib.licenses.openldap;
    maintainers = [ ];
  };
})
