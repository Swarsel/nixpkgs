{
  lib,
  stdenv,
  buildPythonPackage,
  equihash,
  python,
  setuptools,
}:

buildPythonPackage rec {
  inherit (equihash)
    version
    src
    ;

  pname = "pyequihash";

  postPatch =
    let
      soext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      substituteInPlace ./equihash/__init__.py --replace-fail \
        "ctypes.util.find_library('equihash') or ctypes.util.find_library('libequihash')" "'${lib.getLib equihash}/lib/libequihash${soext}'"
    '';

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} test.py

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "equihash" ];
  sourceRoot = "${src.name}/python";

  meta = {
    inherit (equihash.meta)
      description
      homepage
      license
      teams
      ;
  };
}
