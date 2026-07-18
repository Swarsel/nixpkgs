{
  lib,
  buildPythonPackage,
  numpy,
  openvino-native,
  packaging,
}:

buildPythonPackage {
  inherit (openvino-native) version;
  pname = "openvino";
  src = openvino-native.python;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -Rv * $out/

    runHook postInstall
  '';

  dependencies = [
    numpy
    packaging
  ];

  pyproject = false;

  pythonImportsCheck = [
    "openvino"
  ];

  meta = {
    description = "OpenVINO(TM) Runtime";
    homepage = "https://github.com/openvinotoolkit/openvino";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
