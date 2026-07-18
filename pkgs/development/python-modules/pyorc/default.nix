{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pkgs,
  pybind11,
  pytestCheckHook,
  python,
  setuptools,
  tzdata,
}:

buildPythonPackage rec {
  pname = "pyorc";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "noirello";
    repo = "pyorc";
    tag = "v${version}";
    hash = "sha256-2w3Qh6g+Yg+D10kTow9YR6B6FhQ+z2DvgDy5GtYxH4g=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        '"pybind11>2.6.0,<3.0"' \
        '"pybind11>2.6.0"'
  '';

  buildInputs = [
    pkgs.lz4
    pkgs.protobuf
    pkgs.snappy
    pkgs.zlib
    pkgs.zstd
    pkgs.apache-orc
  ];

  env = {
    PYORC_SKIP_ORC_BUILD = "true";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pkgs.apache-orc
  ];

  preCheck = ''
    # provide timezone data, works only on linux
    export TZDIR=${tzdata}/${python.sitePackages}/tzdata/zoneinfo

    substituteInPlace "tests/compare/test_writer_cmp.py" \
      --replace-fail "deps/bin/orc-contents" "orc-contents"

    substituteInPlace "tests/compare/test_reader_cmp.py" \
      --replace-fail "deps/bin/orc-metadata" "orc-metadata"

    mkdir -p deps
    ln -s "${pkgs.apache-orc.src}/examples" "deps/"
  '';

  build-system = [
    pybind11
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyorc"
  ];

  meta = {
    description = "Python module for Apache ORC file format";
    homepage = "https://github.com/noirello/pyorc";
    changelog = "https://github.com/noirello/pyorc/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
