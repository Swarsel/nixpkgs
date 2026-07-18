{
  buildPythonPackage,
  numpy,
  python,
  sherpa-onnx,
}:

buildPythonPackage {
  inherit (sherpa-onnx) version;
  pname = "sherpa-onnx";
  src = sherpa-onnx.python;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${python.sitePackages}
    cp -Rv * $out/${python.sitePackages}/

    runHook postInstall
  '';

  dependencies = [ numpy ];
  pyproject = false;
  pythonImportsCheck = [ "sherpa_onnx" ];

  meta = removeAttrs sherpa-onnx.meta [ "mainProgram" ] // {
    description = "Python bindings for sherpa-onnx speech recognition";
  };
}
