{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xstatic-jquery";
  version = "3.5.1.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-4K6PjsW70oBFukvKBnZ6OL1fwnz5tx9DRYn1k3Dc0yM=";
    pname = "XStatic-jQuery";
  };

  # no tests implemented
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xstatic.pkg.jquery" ];

  meta = {
    description = "jquery packaged static files for python";
    homepage = "https://jquery.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ makefu ];
  };
})
