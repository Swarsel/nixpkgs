{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xstatic";
  version = "1.0.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-QCVEzJ4XlIlEEFTwnIB4BOEV6iRpB96HwDVftPWjEmg=";
    pname = "XStatic";
  };

  # no tests implemented
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xstatic" ];

  meta = {
    description = "Base packaged static files for python";
    homepage = "https://github.com/xstatic-py/xstatic";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ makefu ];
  };
})
