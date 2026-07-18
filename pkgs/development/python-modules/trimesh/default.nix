{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  charset-normalizer,
  # optional deps
  colorlog,
  embreex,
  httpx,
  jsonschema,
  lxml,
  manifold3d,
  mapbox-earcut,
  networkx,
  numpy,
  pillow,
  pycollada,
  pytestCheckHook,
  rtree,
  scipy,
  setuptools,
  shapely,
  svg-path,
  xxhash,
}:

buildPythonPackage (finalAttrs: {
  pname = "trimesh";
  version = "4.12.2";

  src = fetchFromGitHub {
    owner = "mikedh";
    repo = "trimesh";
    tag = finalAttrs.version;
    hash = "sha256-Zef/BCheJWJNkK+ligeAMmuI3EX4uGfcNNbEJ9BNngY=";
  };

  nativeCheckInputs = [
    lxml
    pytestCheckHook
  ]
  # embreex is maintained by trimesh devs
  ++ lib.optionals embreex.meta.available [
    embreex
    rtree
  ];

  build-system = [ setuptools ];
  dependencies = [ numpy ];

  disabledTests = [
    # requires loading models which aren't part of the Pypi tarball
    "test_load"
  ]
  ++ lib.optionals embreex.meta.available [
    # requires manifold3d
    "test_contains_cavity"
  ];

  enabledTestPaths = [
    "tests/test_minimal.py"
  ]
  ++ lib.optionals embreex.meta.available [
    "tests/test_ray.py"
  ];

  optional-dependencies = {
    easy = [
      colorlog
      manifold3d
      charset-normalizer
      lxml
      jsonschema
      networkx
      svg-path
      pycollada
      shapely
      xxhash
      rtree
      httpx
      scipy
      pillow
      # vhacdx # not packaged
      mapbox-earcut
    ]
    ++ lib.optionals embreex.meta.available [
      embreex
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "trimesh"
    "trimesh.ray"
    "trimesh.path"
    "trimesh.path.exchange"
    "trimesh.scene"
    "trimesh.voxel"
    "trimesh.visual"
    "trimesh.viewer"
    "trimesh.exchange"
    "trimesh.resources"
    "trimesh.interfaces"
  ];

  meta = {
    description = "Python library for loading and using triangular meshes";
    homepage = "https://trimesh.org/";
    changelog = "https://github.com/mikedh/trimesh/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pbsds
    ];

    mainProgram = "trimesh";
  };
})
