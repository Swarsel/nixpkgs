{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "multiset";
  version = "3.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fFmnhihLnDOd9PIZ3LtM5fRNOsGyD5ImNsTXieic97U=";
  };

  postPatch = ''
    # Drop broken version specifier
    sed -i '/python_requires/d' setup.cfg
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "multiset" ];

  meta = {
    description = "Implementation of a multiset";
    homepage = "https://github.com/wheerd/multiset";
    changelog = "https://github.com/wheerd/multiset/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
