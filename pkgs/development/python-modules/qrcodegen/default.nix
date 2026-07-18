{
  lib,
  buildPythonPackage,
  python,
  qrcodegen,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  inherit (qrcodegen)
    version
    src
    ;

  pname = "qrcodegen";

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} qrcodegen-demo.py

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "qrcodegen" ];
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    inherit (qrcodegen.meta)
      description
      homepage
      license
      maintainers
      platforms
      ;
  };
})
