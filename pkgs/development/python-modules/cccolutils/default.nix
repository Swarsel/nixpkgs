{
  lib,
  buildPythonPackage,
  fetchPypi,
  git,
  gitpython,
  krb5-c, # C krb5 library, not PyPI krb5
  mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cccolutils";
  version = "1.5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-YzKjG43biRbTZKtzSUHHhtzOfcZfzISHDFolqzrBjL8=";
    pname = "CCColUtils";
  };

  buildInputs = [ krb5-c ];
  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    git
    gitpython
    mock
  ];

  pyproject = true;
  pythonImportsCheck = [ "cccolutils" ];

  meta = {
    description = "Python Kerberos 5 Credential Cache Collection Utilities";
    homepage = "https://pagure.io/cccolutils";
    license = lib.licenses.gpl2Plus;
  };
})
