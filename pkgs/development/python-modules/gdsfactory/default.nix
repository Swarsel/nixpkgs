{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  # build-system
  flit-core,
  freetype-py,
  graphviz,
  ipykernel,
  # dependencies
  jinja2,
  # tests
  jsondiff,
  jsonschema,
  kfactory,
  loguru,
  mapbox-earcut,
  matplotlib,
  natsort,
  networkx,
  numpy,
  orjson,
  pandas,
  pydantic,
  pydantic-extra-types,
  pydantic-settings,
  pyglet,
  pytest-regressions,
  pytestCheckHook,
  pythonRelaxDepsHook,
  pyyaml,
  qrcode,
  rectpack,
  rich,
  scikit-image,
  scipy,
  shapely,
  toolz,
  trimesh,
  typer,
  types-pyyaml,
  typing-extensions,
  watchdog,
}:
buildPythonPackage (finalAttrs: {
  pname = "gdsfactory";
  version = "9.45.0";

  src = fetchFromGitHub {
    owner = "gdsfactory";
    repo = "gdsfactory";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BO/4SoD2qSPfNGwRJTMpkbeZc8Zez7Xy23CgX9CIqC0=";
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  # tests require >32GB of RAM
  doCheck = false;

  nativeCheckInputs = [
    jsondiff
    jsonschema
    pytest-regressions
    pytestCheckHook
  ];

  build-system = [
    flit-core
  ];

  dependencies = [
    jinja2
    loguru
    matplotlib
    natsort
    numpy
    orjson
    pandas
    pydantic
    pydantic-settings
    pydantic-extra-types
    pyyaml
    qrcode
    rectpack
    rich
    scipy
    shapely
    toolz
    types-pyyaml
    typer
    kfactory
    watchdog
    freetype-py
    mapbox-earcut
    networkx
    scikit-image
    trimesh
    ipykernel
    attrs
    graphviz
    pyglet
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "gdsfactory" ];

  pythonRelaxDeps = [
    "pydantic"
    "trimesh"
    "kfactory"
  ];

  meta = {
    description = "Python library to generate GDS layouts";
    homepage = "https://github.com/gdsfactory/gdsfactory";
    changelog = "https://github.com/gdsfactory/gdsfactory/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fbeffa ];
  };
})
