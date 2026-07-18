{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  clipper2,
  cmake,
  manifold,
  nanobind,
  ninja,
  numpy,
  onetbb,
  pkg-config,
  pytestCheckHook,
  python,
  scikit-build-core,
  trimesh,
}:

buildPythonPackage {
  inherit (manifold) version src;
  pname = "manifold3d";

  buildInputs = [
    onetbb
    clipper2
  ];

  nativeCheckInputs = [
    pytestCheckHook
    trimesh
  ];

  preCheck = ''
    ${python.interpreter} bindings/python/examples/run_all.py
  '';

  build-system = [
    scikit-build-core
    cmake
    ninja
    nanobind
    pkg-config
  ];

  dependencies = [
    numpy
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "manifold3d"
  ];

  meta = {
    inherit (manifold.meta)
      homepage
      changelog
      description
      license
      ;

    maintainers = with lib.maintainers; [
      pbsds
      pca006132
    ];
  };
}
