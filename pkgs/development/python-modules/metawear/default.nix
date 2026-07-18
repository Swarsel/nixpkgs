{
  lib,
  bluez,
  boost,
  buildPythonPackage,
  cython,
  fetchPypi,
  nlohmann_json,
  pyserial,
  requests,
  warble,
}:

buildPythonPackage rec {
  pname = "metawear";
  version = "1.0.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gNEI6P6GslNd1DzFwCFndVIfUvSTPYollGdqkZhQ4Y8=";
  };

  postPatch = ''
    # remove vendored nlohmann_json
    rm MetaWear-SDK-Cpp/src/metawear/dfu/cpp/json.hpp
    substituteInPlace MetaWear-SDK-Cpp/src/metawear/dfu/cpp/file_operations.cpp \
        --replace '#include "json.hpp"' '#include <nlohmann/json.hpp>'
  '';

  nativeBuildInputs = [ cython ];

  buildInputs = [
    boost
    bluez
    nlohmann_json
  ];

  propagatedBuildInputs = [
    pyserial
    requests
    warble
  ];

  enableParallelBuilding = true;
  format = "setuptools";

  pythonImportsCheck = [
    "mbientlab"
    "mbientlab.metawear"
  ];

  meta = {
    description = "Python bindings for the MetaWear C++ SDK by MbientLab";
    homepage = "https://github.com/mbientlab/metawear-sdk-python";
    license = with lib.licenses; [ unfree ];
    maintainers = with lib.maintainers; [ stepbrobd ];
    platforms = lib.platforms.linux;
  };
}
