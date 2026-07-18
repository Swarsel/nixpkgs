{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  xstatic-jquery,
}:

buildPythonPackage (finalAttrs: {
  pname = "xstatic-jquery-ui";
  version = "1.13.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Npfl8O81W49KHHJCIVkmg8LbAxk1y7V7RiJO70dL0pQ=";
    pname = "XStatic-jquery-ui";
  };

  # no tests implemented
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ xstatic-jquery ];
  pyproject = true;
  pythonImportsCheck = [ "xstatic.pkg.jquery_ui" ];

  meta = {
    description = "jquery-ui packaged static files for python";
    homepage = "https://jqueryui.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ makefu ];
  };
})
