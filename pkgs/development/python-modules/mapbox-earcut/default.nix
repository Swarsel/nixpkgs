{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  nanobind,
  ninja,
  # dependencies
  numpy,
  # tests
  pytestCheckHook,
  scikit-build-core,
}:

buildPythonPackage rec {
  pname = "mapbox-earcut";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "skogler";
    repo = "mapbox_earcut_python";
    tag = "v${version}";
    hash = "sha256-R5YDJbfDNf6jAvG3VJQMYay6i8dw616SUs0tPgrJt6I=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf mapbox_earcut
  '';

  build-system = [
    nanobind
    scikit-build-core
  ];

  dependencies = [ numpy ];
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "mapbox_earcut" ];

  meta = {
    description = "Mapbox-earcut fast triangulation of 2D-polygons";

    longDescription = ''
      Python bindings for the C++ implementation of the Mapbox Earcut
      library, which provides very fast and quite robust triangulation of 2D
      polygons.
    '';

    homepage = "https://github.com/skogler/mapbox_earcut_python";
    changelog = "https://github.com/skogler/mapbox_earcut_python/releases/tag/${src.tag}";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
}
