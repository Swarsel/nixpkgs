{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "dash-core-components";
  version = "2.0.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-xnM4dK+XXlUvlaE5ihbC7n3xTOQ/pguzcYo8bgtj/+4=";
    pname = "dash_core_components";
  };

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Dash component starter pack";
    homepage = "https://dash.plot.ly/dash-core-components";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
