{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  # tests
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  # native dependencies
  zlib-ng,
}:

buildPythonPackage rec {
  pname = "zlib-ng";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "pycompression";
    repo = "python-zlib-ng";
    rev = "v${version}";
    hash = "sha256-t/PSby1LUTyp+7XXKZTWjRrPvAei1ZrGSGU2CIcAQBc=";
  };

  buildInputs = [ zlib-ng ];
  env.PYTHON_ZLIB_NG_LINK_DYNAMIC = true;
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf src
  '';

  build-system = [
    cmake
    setuptools
    setuptools-scm
  ];

  disabledTests = [
    # commandline tests fail to find the built module
    "test_compress_fast_best_are_exclusive"
    "test_compress_infile_outfile"
    "test_compress_infile_outfile_default"
    "test_decompress_cannot_have_flags_compression"
    "test_decompress_infile_outfile"
    "test_decompress_infile_outfile_error"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "zlib_ng" ];

  meta = {
    description = "Drop-in replacement for Python's zlib and gzip modules using zlib-ng";
    homepage = "https://github.com/pycompression/python-zlib-ng";
    changelog = "https://github.com/pycompression/python-zlib-ng/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
