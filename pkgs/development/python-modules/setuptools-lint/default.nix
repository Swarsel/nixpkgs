{
  lib,
  buildPythonPackage,
  fetchPypi,
  pylint,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "setuptools-lint";
  version = "0.6.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-55ThXHyN3pcLYY2cetRYiurqBn8DTMtK6PrMYwtTQZk=";
    pname = "setuptools-lint";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pylint ];
  pyproject = true;
  pythonImportsCheck = [ "setuptools_lint" ];

  meta = {
    description = "Package to expose pylint as a lint command into setup.py";
    homepage = "https://github.com/johnnoone/setuptools-pylint";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ nickhu ];
  };
})
