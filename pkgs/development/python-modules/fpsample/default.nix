{
  lib,
  buildPythonPackage,
  cmake,
  fetchPypi,
  ninja,
  numpy,
  pybind11,
  scikit-build-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "fpsample";
  version = "1.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-XiX5fANBLSQ3Z/ueR/e21sc2x84enVGRiJTj/TJ3SfI=";
  };

  build-system = [
    cmake
    ninja
    pybind11
    scikit-build-core
  ];

  dependencies = [ numpy ];
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "fpsample" ];

  meta = {
    description = "Efficient CPU farthest-point sampling for point clouds";
    homepage = "https://github.com/leonardodalinky/fpsample";
    changelog = "https://github.com/leonardodalinky/fpsample/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ BatteredBunny ];
  };
})
