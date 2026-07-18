{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  geojson,
  google-api-core,
  hatchling,
  imagesize,
  mypy,
  nbconvert,
  nbformat,
  numpy,
  opencv-python-headless,
  pillow,
  pydantic,
  pyproj,
  pytest-cov-stub,
  pytest-order,
  pytest-rerunfailures,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  requests,
  shapely,
  strenum,
  tqdm,
  typeguard,
  typing-extensions,
}:

let
  version = "7.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Labelbox";
    repo = "labelbox-python";
    tag = "v${version}";
    hash = "sha256-l+2BSkfZIwu0d3hEB7jq3CzampRYkNA9jaJnMlode68=";
  };

  lbox-clients = buildPythonPackage {
    inherit src version pyproject;
    pname = "lbox-clients";
    doCheck = true;

    nativeCheckInputs = [
      pytestCheckHook
      pytest-cov-stub
    ];

    __darwinAllowLocalNetworking = true;
    build-system = [ hatchling ];

    dependencies = [
      google-api-core
      requests
    ];

    sourceRoot = "${src.name}/libs/lbox-clients";
  };
in
buildPythonPackage rec {
  inherit src version pyproject;
  pname = "labelbox";
  doCheck = true;

  nativeCheckInputs = [
    nbconvert
    nbformat
    pytest-cov-stub
    pytest-order
    pytest-rerunfailures
    pytest-xdist
    pytestCheckHook
  ]
  ++ optional-dependencies.data;

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    google-api-core
    lbox-clients
    pydantic
    python-dateutil
    requests
    strenum
    tqdm
    geojson
    mypy
    pyyaml
  ];

  disabledTestPaths = [
    # Requires network access
    "tests/integration"
    # Missing requirements
    "tests/data"
    "tests/unit/test_label_data_type.py"
  ];

  optional-dependencies = {
    data = [
      shapely
      numpy
      pillow
      opencv-python-headless
      typeguard
      imagesize
      pyproj
      # pygeotile
      typing-extensions
    ];
  };

  pythonImportsCheck = [ "labelbox" ];

  pythonRelaxDeps = [
    "mypy"
    "python-dateutil"
  ];

  sourceRoot = "${src.name}/libs/labelbox";

  meta = {
    description = "Platform API for LabelBox";
    homepage = "https://github.com/Labelbox/labelbox-python";
    changelog = "https://github.com/Labelbox/labelbox-python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rakesh4g ];
  };
}
