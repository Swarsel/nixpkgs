{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  pygccxml,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pybindgen";
  version = "0.22.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-jH8iORpJqEUY9aKtBuOlseg50Q402nYxUZyKKPy6N2Q=";
    pname = "PyBindGen";
  };

  buildInputs = [ setuptools-scm ];
  # Fails to import module 'cxxfilt' from pygccxml on Py3k
  doCheck = (!isPy3k);
  nativeCheckInputs = [ pygccxml ];
  format = "setuptools";
  pythonImportsCheck = [ "pybindgen" ];

  meta = {
    description = "Python Bindings Generator";
    homepage = "https://github.com/gjcarneiro/pybindgen";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ teto ];
  };
})
