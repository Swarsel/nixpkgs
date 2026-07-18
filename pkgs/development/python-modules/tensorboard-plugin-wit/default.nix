{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "tensorboard_plugin_wit";
  version = "1.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0nv855qm2fav70lndsrv810pqgg41sbmd70fk86wk18ih825yxzf";
    format = "wheel";
    python = "py3";
  };

  format = "wheel";

  meta = {
    description = "What-If Tool TensorBoard plugin";
    homepage = "http://tensorflow.org";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ndl ];
  };
}
