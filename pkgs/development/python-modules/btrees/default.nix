{
  lib,
  buildPythonPackage,
  fetchPypi,
  persistent,
  python,
  setuptools,
  transaction,
  zope-interface,
  zope-testrunner,
}:

buildPythonPackage rec {
  pname = "btrees";
  version = "6.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Fga9/6erKMaACYRUC2le7oSPbhWwFF2Fj/SwxiZOjtI=";
  };

  nativeCheckInputs = [
    transaction
    zope-testrunner
  ];

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} -m zope.testrunner --test-path=src --auto-color --auto-progress

    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    persistent
    zope-interface
  ];

  pyproject = true;

  pythonImportsCheck = [
    "BTrees.OOBTree"
    "BTrees.IOBTree"
    "BTrees.IIBTree"
    "BTrees.IFBTree"
  ];

  meta = {
    description = "Scalable persistent components";
    homepage = "http://packages.python.org/BTrees";
    changelog = "https://github.com/zopefoundation/BTrees/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
