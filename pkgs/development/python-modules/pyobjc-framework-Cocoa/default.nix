{
  lib,
  # TODO: Clean up on `staging`.
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  darwin,
  llvmPackages,
  pyobjc-core,
  setuptools,
}:

buildPythonPackage rec {
  inherit (pyobjc-core) version src;
  pname = "pyobjc-framework-Cocoa";
  patches = pyobjc-core.patches or [ ];

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
  ]
  # TODO: Clean up on `staging`.
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.lld
  ];

  buildInputs = [
    darwin.libffi
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${darwin.libffi.dev}/include"
    "-Wno-error=unused-command-line-argument"
  ];

  # TODO: Clean up on `staging`.
  env.NIX_CFLAGS_LINK = "-fuse-ld=lld";
  build-system = [ setuptools ];
  dependencies = [ pyobjc-core ];
  pyproject = true;

  pythonImportsCheck = [
    "Cocoa"
    "CoreFoundation"
    "Foundation"
    "AppKit"
    "PyObjCTools"
  ];

  sourceRoot = "${src.name}/pyobjc-framework-Cocoa";

  meta = {
    description = "PyObjC wrappers for the Cocoa frameworks on macOS";
    homepage = "https://github.com/ronaldoussoren/pyobjc/tree/main/pyobjc-framework-Cocoa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
    platforms = lib.platforms.darwin;
  };
}
