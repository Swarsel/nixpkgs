{
  lib,
  stdenv,
  bitstring,
  buildPackages,
  buildPythonPackage,
  cffi,
  fetchPypi,
  pycparser,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyvex";
  version = "9.2.154";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-a3ei2w66v18QKAofpPvDUoM42zHRHPrNQic+FE+rLKY=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace vex/Makefile-gcc \
      --replace-fail '/usr/bin/ar' 'ar'
  '';

  nativeBuildInputs = [ cffi ];

  preBuild = ''
    export CC=${stdenv.cc.targetPrefix}cc
    substituteInPlace pyvex_c/Makefile \
      --replace-fail 'AR=ar' 'AR=${stdenv.cc.targetPrefix}ar'
  '';

  # No tests are available on PyPI, GitHub release has tests
  # Switch to GitHub release after all angr parts are present
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    bitstring
    cffi
    pycparser
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  pyproject = true;
  pythonImportsCheck = [ "pyvex" ];

  setupPyBuildFlags = lib.optionals stdenv.hostPlatform.isLinux [
    "--plat-name"
    "linux"
  ];

  meta = {
    description = "Python interface to libVEX and VEX IR";
    homepage = "https://github.com/angr/pyvex";

    license = with lib.licenses; [
      bsd2
      gpl3Plus
      lgpl3Plus
    ];

    maintainers = with lib.maintainers; [ fab ];
  };
})
