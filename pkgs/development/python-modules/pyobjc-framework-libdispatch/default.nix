{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  darwin,
  pyobjc-core,
  pyobjc-framework-Cocoa,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  inherit (pyobjc-core) version src;
  pname = "pyobjc-framework-libdispatch";
  patches = pyobjc-core.patches or [ ];

  # See https://github.com/ronaldoussoren/pyobjc/pull/641. Unfortunately, we
  # cannot just pull that diff with fetchpatch due to https://discourse.nixos.org/t/how-to-apply-patches-with-sourceroot/59727.
  postPatch = ''
    substituteInPlace pyobjc_setup.py \
      --replace-fail "-buildversion" "-buildVersion" \
      --replace-fail "-productversion" "-productVersion" \
      --replace-fail "/usr/bin/" ""
  '';

  nativeBuildInputs = [
    darwin.DarwinTools # sw_vers
  ];

  buildInputs = [
    darwin.libffi
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${darwin.libffi.dev}/include"
    "-Wno-error=unused-command-line-argument"
  ];

  nativeCheckInputs = [
    unittestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyobjc-core
    pyobjc-framework-Cocoa
  ];

  pyproject = true;

  pythonImportsCheck = [
    "dispatch"
    "libdispatch"
  ];

  sourceRoot = "${src.name}/pyobjc-framework-libdispatch";

  meta = {
    description = "PyObjC wrappers for the libdispatch framework on macOS";
    homepage = "https://github.com/ronaldoussoren/pyobjc/tree/main/pyobjc-framework-libdispatch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
    platforms = lib.platforms.darwin;
  };
}
