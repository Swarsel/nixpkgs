{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  cxxopts,
  docling-core,
  libjpeg,
  loguru-cpp,
  nlohmann_json,
  pillow,
  pkg-config,
  pybind11,
  pydantic,
  pytestCheckHook,
  qpdf,
  setuptools,
  # python dependencies
  tabulate,
  utf8cpp,
  zlib,
}:

buildPythonPackage rec {
  pname = "docling-parse";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "docling-project";
    repo = "docling-parse";
    tag = "v${version}";
    hash = "sha256-qxD3ryU1jXf8Gm5/IiG2NTOnRgA6HADPfgBj6Kn+Pj4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        '"cmake>=3.27.0,<4.0.0"' \
        '"cmake>=3.27.0"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    pybind11
    cxxopts
    libjpeg
    loguru-cpp
    nlohmann_json
    qpdf
    utf8cpp
    zlib
  ];

  cmakeFlags = [
    "-DUSE_SYSTEM_DEPS=True"
  ];

  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev utf8cpp}/include/utf8cpp";
  env.USE_SYSTEM_DEPS = true;

  # Listed as runtime dependencies but only used in CI to build wheels
  preBuild = ''
    sed -i '/cibuildwheel/d' pyproject.toml
    sed -i '/delocate/d' pyproject.toml
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    tabulate
    pillow
    pydantic
    docling-core
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "docling_parse"
  ];

  pythonRelaxDeps = [
    "pydantic"
    "pillow"
  ];

  meta = {
    description = "Simple package to extract text with coordinates from programmatic PDFs";
    homepage = "https://github.com/DS4SD/docling-parse";
    changelog = "https://github.com/DS4SD/docling-parse/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    # error: no matching conversion for functional-style cast from 'bool' to 'nlohmann::basic_json<>'
    # See https://github.com/docling-project/docling-parse/issues/172 for context
    broken = true;
  };
}
