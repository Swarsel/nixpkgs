{
  lib,
  buildPythonPackage,
  fetchPypi,
  onnx,
  paddlepaddle,
  python,
  pythonAtLeast,
  pythonOlder,
}:
let
  pname = "paddle2onnx";
  version = "2.0.1";
  format = "wheel";
  pyShortVersion = "cp${builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion}";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RCD6iTvzhGrFjW02lasTwQoM+Xa68Q5b6Ito3KvqdHg=";
    abi = pyShortVersion;
    dist = pyShortVersion;
    format = "wheel";
    platform = "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    python = pyShortVersion;
  };
in
buildPythonPackage {
  inherit
    pname
    version
    src
    format
    ;

  dependencies = [
    onnx
    paddlepaddle
  ];

  disabled = pythonOlder "3.12" || pythonAtLeast "3.13";

  meta = {
    description = "ONNX Model Exporter for PaddlePaddle";
    homepage = "https://github.com/PaddlePaddle/Paddle2ONNX";
    changelog = "https://github.com/PaddlePaddle/Paddle2ONNX/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "paddle2onnx";
  };
}
