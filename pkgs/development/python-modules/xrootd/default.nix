{
  lib,
  buildPythonPackage,
  cmake,
  setuptools,
  xrootd,
}:

buildPythonPackage rec {
  inherit (xrootd) version src;
  pname = "xrootd";
  buildInputs = [ xrootd ];

  env.CMAKE_ARGS = lib.toString [
    (lib.cmakeFeature "XRootD_INCLUDE_DIR" "${lib.getDev xrootd}/include/xrootd;${src}/src")
  ];

  # Tests are only compatible with Python 2
  doCheck = false;

  build-system = [
    cmake
    setuptools
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "XRootD" ];
  sourceRoot = "${src.name}/python";

  meta = {
    description = "XRootD central repository";
    homepage = "https://github.com/xrootd/xrootd";
    changelog = "https://github.com/xrootd/xrootd/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
