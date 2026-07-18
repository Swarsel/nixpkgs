{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  bzip2,
  cmake,
  expat,
  isPyPy,
  libosmium,
  lz4,
  ninja,
  protozero,
  pybind11,
  pytest-httpserver,
  pytestCheckHook,
  requests,
  scikit-build-core,
  shapely,
  werkzeug,
  zlib,
}:

buildPythonPackage rec {
  pname = "pyosmium";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "pyosmium";
    tag = "v${version}";
    hash = "sha256-lEkT+3R6200XarMW1oZcOzMLPviDcpG8kQilXVWOyu0=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libosmium
    protozero
    expat
    bzip2
    zlib
    pybind11
    lz4
  ];

  preBuild = "cd ..";

  nativeCheckInputs = [
    pytestCheckHook
    shapely
    werkzeug
    pytest-httpserver
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    scikit-build-core
    ninja
  ];

  dependencies = [ requests ];
  disabled = isPyPy;
  pyproject = true;

  meta = {
    description = "Python bindings for libosmium";
    homepage = "https://osmcode.org/pyosmium";
    changelog = "https://github.com/osmcode/pyosmium/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ sikmir ];
  };
}
