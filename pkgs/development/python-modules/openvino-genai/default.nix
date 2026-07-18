{
  lib,
  buildPythonPackage,
  numpy,
  openvino-genai-native,
  openvino-tokenizers,
  python,
}:

buildPythonPackage {
  inherit (openvino-genai-native) version;
  pname = "openvino-genai";
  src = openvino-genai-native.python;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${python.sitePackages}
    cp -R * $out/${python.sitePackages}/

    runHook postInstall
  '';

  dependencies = [
    numpy
    # openvino-genai loads tokenizers via py::module_::import("openvino_tokenizers")
    # at runtime, so the Python wrapper must be available on the import path.
    openvino-tokenizers
  ];

  pyproject = false;
  pythonImportsCheck = [ "openvino_genai" ];

  meta = {
    description = "OpenVINO GenAI Python API";
    homepage = "https://github.com/openvinotoolkit/openvino.genai";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jpds ];
  };
}
