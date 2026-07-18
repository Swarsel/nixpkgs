{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  paho-mqtt,
  pandas,
  pycryptodome,
  requests,
  setuptools,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pyezvizapi";
  version = "1.0.5.0";

  src = fetchFromGitHub {
    owner = "RenierM26";
    repo = "pyEzvizApi";
    tag = "v${version}";
    hash = "sha256-m3rj8ELu8/X/3TPtC1wfN8VOs7eHKb4DNvb7JAoKXfE=";
  };

  # test_cam_rtsp.py is not actually a unit test
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    paho-mqtt
    pandas
    pycryptodome
    requests
    xmltodict
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyezvizapi" ];

  meta = {
    description = "Python interface for for Ezviz cameras";
    homepage = "https://github.com/RenierM26/pyEzvizApi";
    changelog = "https://github.com/RenierM26/pyEzvizApi/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "pyezviz";
  };
}
