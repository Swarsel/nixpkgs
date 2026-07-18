{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  # buildInputs
  laszip,
  ninja,
  pybind11,
  # build-system
  scikit-build-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "laszip-python";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "tmontaigu";
    repo = "laszip-python";
    tag = finalAttrs.version;
    hash = "sha256-fg9Joe5iDNT4w2j+zQuQIoxyAYpCAgLwhuqsBsJn6lU=";
  };

  buildInputs = [ laszip ];
  # There are no tests
  doCheck = false;

  build-system = [
    cmake
    ninja
    pybind11
    scikit-build-core
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "laszip" ];

  meta = {
    description = "Unofficial bindings between Python and LASzip made using pybind11";
    homepage = "https://github.com/tmontaigu/laszip-python";
    changelog = "https://github.com/tmontaigu/laszip-python/blob/${finalAttrs.src.tag}/Changelog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
})
