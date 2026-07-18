{
  lib,
  stdenv,
  ble-serial,
  buildPythonPackage,
  liboprf,
  pyserial,
  pyserial-asyncio,
  pysodium,
  pytestCheckHook,
  pyudev,
  securestring,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  inherit (liboprf)
    version
    src
    ;

  pname = "pyoprf";

  postPatch =
    let
      soext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      substituteInPlace ./pyoprf/__init__.py --replace-fail \
        "ctypes.util.find_library('oprf') or ctypes.util.find_library('liboprf')" "'${lib.getLib liboprf}/lib/liboprf${soext}'"
      substituteInPlace pyoprf/noisexk.py \
        --replace-fail "ctypes.util.find_library('oprf-noiseXK')" "'${lib.getLib liboprf}/lib/liboprf-noiseXK${soext}'" \
        --replace-fail "or ctypes.util.find_library('liboprf-noiseXK')" ""
    '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    ble-serial
    pyserial
    pyserial-asyncio
    pysodium
    pyudev
    securestring
  ];

  enabledTestPaths = [ "tests/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "pyoprf" ];
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    inherit (liboprf.meta)
      description
      changelog
      license
      teams
      ;

    homepage = "https://github.com/stef/liboprf/tree/master/python";
  };
})
