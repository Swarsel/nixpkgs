{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  keystone,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "keystone-engine";
  version = "0.9.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "1xahdr6bh3dw5swrc2r8kqa8ljhqlb7k2kxv5mrw5rhcmcnzcyig";
  };

  preConfigure = ''
    substituteInPlace setup.py --replace \
      "libkeystone" "${keystone}/lib/libkeystone"
  '';

  # No tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "keystone" ];

  setupPyBuildFlags = lib.optionals stdenv.hostPlatform.isLinux [
    "--plat-name"
    "linux"
  ];

  meta = {
    description = "Lightweight multi-platform, multi-architecture assembler framework";
    homepage = "https://www.keystone-engine.org";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dump_stack ];
  };
})
