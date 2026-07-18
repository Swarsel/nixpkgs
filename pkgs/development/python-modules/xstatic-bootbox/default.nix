{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xstatic-bootbox";
  version = "5.5.1.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-SyEguzOh2K2o+eBTKtmZh6oDh5sXsIv9xrgybW63wgU=";
    pname = "XStatic-Bootbox";
  };

  # no tests implemented
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xstatic.pkg.bootbox" ];

  meta = {
    description = "Bootboxjs packaged static files for python";
    homepage = "https://bootboxjs.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ makefu ];
  };
})
