{
  lib,
  buildPythonPackage,
  # dependencies
  fastcrc,
  fetchPypi,
  msgspec,
  numpy,
  # build-system
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "apycula";
  version = "0.32";

  # The Pypi archive contains necessary files generated with proprietary tools.
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-DWSVcIXkv6g6Zf+8SrZKQUrtOD5RKu01Xl/lo8Ov5n8=";
  };

  # Tests require a physical FPGA
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    fastcrc
    msgspec
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "apycula" ];

  meta = {
    description = "Open Source tools for Gowin FPGAs";
    homepage = "https://github.com/YosysHQ/apicula";
    changelog = "https://github.com/YosysHQ/apicula/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ newam ];
  };
})
