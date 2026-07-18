{
  lib,
  buildPythonPackage,
  darwin,
  pyobjc-core,
  pyobjc-framework-Cocoa,
  setuptools,
}:

buildPythonPackage rec {
  inherit (pyobjc-core) version src;
  pname = "pyobjc-framework-WebKit";

  # See https://github.com/ronaldoussoren/pyobjc/pull/641. Unfortunately, we
  # cannot just pull that diff with fetchpatch due to https://discourse.nixos.org/t/how-to-apply-patches-with-sourceroot/59727.
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
  ];

  pyproject = true;

  pythonImportsCheck = [
    "WebKit"
    "JavaScriptCore"
    "PyObjCTools"
  ];

  sourceRoot = "${src.name}/pyobjc-framework-WebKit";

  meta = {
    description = "PyObjC wrappers for the WebKit frameworks on macOS";
    homepage = "https://github.com/ronaldoussoren/pyobjc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
    platforms = lib.platforms.darwin;
  };
}
