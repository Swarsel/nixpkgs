{
  lib,
  buildPythonPackage,
  fetchPypi,
  pybluez,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bt-proximity";
  version = "0.2.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-+F2Ydjz/VxnYEuXfggnNUDFaLXLSh1GKAX/RtUNykXY=";
    pname = "bt_proximity";
  };

  # there are no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pybluez ];
  pyproject = true;
  pythonImportsCheck = [ "bt_proximity" ];

  meta = {
    description = "Bluetooth Proximity Detection using Python";
    homepage = "https://github.com/FrederikBolding/bluetooth-proximity";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ peterhoeg ];
  };
})
