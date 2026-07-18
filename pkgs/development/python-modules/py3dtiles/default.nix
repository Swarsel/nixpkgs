{
  lib,
  fetchFromGitLab,
  addBinToPathHook,
  buildPythonPackage,
  # optional-dependencies
  ifcopenshell,
  lark,
  laspy,
  # dependencies
  lz4,
  mapbox-earcut,
  moreutils,
  numba,
  numpy,
  plyfile,
  psutil,
  psycopg2-binary,
  pygltflib,
  pyproj,
  # tests
  pytest-benchmark,
  pytest-cov-stub,
  pytestCheckHook,
  pyzmq,
  # build-system
  setuptools,
  setuptools-scm,
  writeText,
}:

buildPythonPackage (finalAttrs: {
  pname = "py3dtiles";
  version = "12.1.1";

  src = fetchFromGitLab {
    owner = "py3dtiles";
    repo = "py3dtiles";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5zKp32Rn+bwUKVPb1XJxenHzRz0V7cgNmRwjWDYyKnI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-benchmark
    pytest-cov-stub
    moreutils # chronic
  ];

  checkInputs = with finalAttrs.passthru.optional-dependencies; ply ++ las ++ ifc;

  nativeInstallCheckInputs = [
    addBinToPathHook
  ];

  # from .gitlab-ci.yml
  # note: nativeCheckInputs are also available for installCheckPhase
  # chronic - runs a command quietly unless it fails
  installCheckPhase =
    let
      testScript = writeText "test.py" /* py */ ''
        from py3dtiles.tileset.utils import number_of_points_in_tileset
        from pathlib import Path
        exit(number_of_points_in_tileset(Path("3dtiles/tileset.json")) != 22300)
      '';
    in
    ''
      runHook preInstallCheck
      chronic py3dtiles info tests/fixtures/pointCloudRGB.pnts
      chronic py3dtiles convert --out test1 ./tests/fixtures/simple.xyz
      chronic py3dtiles convert --out test2 ./tests/fixtures/with_srs_3857.las
      chronic py3dtiles convert tests/fixtures/simple.ply
      chronic python ${testScript}
      runHook pytestCheckPhase
      runHook postInstallCheck
    '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    lz4
    mapbox-earcut
    numba
    numpy
    psutil
    pygltflib
    pyproj
    pyzmq
  ];

  optional-dependencies = {
    ifc = [
      ifcopenshell
      lark
    ];

    las = [
      laspy
    ];

    ply = [
      plyfile
    ];

    postgres = [
      psycopg2-binary
    ];
  };

  pyproject = true;
  # disable benchmarks to reduce load on the builder
  pytestFlags = [ "--benchmark-disable" ];

  pythonImportsCheck = [
    "py3dtiles"
  ];

  pythonRelaxDeps = [
    "mapbox_earcut"
    "numba"
    "numpy"
    "pyzmq"
  ];

  meta = {
    description = "Python module to manage 3DTiles format";
    homepage = "https://py3dtiles.org";
    changelog = "https://py3dtiles.org/main/changelog.html";
    license = lib.licenses.asl20;
    mainProgram = "py3dtiles";
    downloadPage = "https://gitlab.com/py3dtiles/py3dtiles";

    teams = with lib.teams; [
      geospatial
      ngi
    ];
  };
})
