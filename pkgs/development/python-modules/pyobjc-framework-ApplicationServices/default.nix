{
  lib,
  buildPythonPackage,
  darwin,
  pyobjc-core,
  pyobjc-framework-Cocoa,
  pyobjc-framework-CoreText,
  pyobjc-framework-Quartz,
  setuptools,
}:

buildPythonPackage rec {
  inherit (pyobjc-core) version src;
  pname = "pyobjc-framework-ApplicationServices";

  # Same workaround as pyobjc-framework-Quartz; see
  # https://github.com/ronaldoussoren/pyobjc/pull/641.
  postPatch = ''
    substituteInPlace pyobjc_setup.py \
      --replace-fail "-buildversion" "-buildVersion" \
      --replace-fail "-productversion" "-productVersion" \
      --replace-fail "/usr/bin/sw_vers" "sw_vers" \
      --replace-fail "/usr/bin/xcrun" "xcrun"
  '';

  nativeBuildInputs = [
    darwin.DarwinTools # sw_vers
  ];

  buildInputs = [ darwin.libffi ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${darwin.libffi.dev}/include"
    "-Wno-error=unused-command-line-argument"
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyobjc-core
    pyobjc-framework-Cocoa
    pyobjc-framework-Quartz
    pyobjc-framework-CoreText
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ApplicationServices"
    "HIServices"
  ];

  sourceRoot = "${src.name}/pyobjc-framework-ApplicationServices";

  meta = {
    description = "PyObjC wrappers for the ApplicationServices framework on macOS";
    homepage = "https://github.com/ronaldoussoren/pyobjc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ l1n ];
    platforms = lib.platforms.darwin;
  };
}
