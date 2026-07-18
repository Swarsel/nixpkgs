{
  lib,
  stdenv,
  buildPythonPackage,
  libopaque,
  pysodium,
  python,
  setuptools,
}:

buildPythonPackage rec {
  inherit (libopaque)
    version
    src
    ;

  pname = "opaque";

  postPatch =
    let
      soext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      substituteInPlace ./opaque/__init__.py --replace-fail \
        "ctypes.util.find_library('opaque') or ctypes.util.find_library('libopaque')" "'${lib.getLib libopaque}/lib/libopaque${soext}'"
    '';

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} test/simple.py

    runHook postCheck
  '';

  build-system = [ setuptools ];
  dependencies = [ pysodium ];
  pyproject = true;
  pythonImportsCheck = [ "opaque" ];
  sourceRoot = "${src.name}/python";

  meta = {
    inherit (libopaque.meta)
      description
      homepage
      license
      teams
      ;
  };
}
