{
  lib,
  buildPythonPackage,
  fetchPypi,
  gviz-api,
  protobuf,
  setuptools,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "tensorboard_plugin_profile";
  version = "2.11.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-t9AZg0BGjDcOxtoRBHZO0joIgLHpoKqEUY4pxmw8sjg=";
    dist = "py3";
    format = "wheel";
    python = "py3";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    gviz-api
    protobuf
    werkzeug
  ];

  format = "wheel";

  meta = {
    description = "Profile Tensorboard Plugin";
    homepage = "http://tensorflow.org";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ndl ];
  };
}
