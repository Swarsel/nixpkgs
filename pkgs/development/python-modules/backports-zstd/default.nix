{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  zstd,
}:

buildPythonPackage rec {
  pname = "backports-zstd";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "rogdham";
    repo = "backports.zstd";
    tag = "v${version}";
    hash = "sha256-0FGYh6o26oeovZ23VYKmmY2nNzDHXIKU8/lBqUxuGQw=";
    fetchSubmodules = true;

    postFetch = ''
      rm -r "$out/src/c/zstd"
    '';
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'ROOT_PATH / "src" / "c" / "zstd"' 'Path("${zstd.src}")'

    # need to preserve $PYTHONPATH when calling sys.executable
    substituteInPlace tests/test/support/script_helper.py \
      --replace-fail "return __cached_interp_requires_environment" "return True"
  '';

  buildInputs = [ zstd ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # sandbox doesn't allow setting SUID bit
    "tests/test/test_tarfile.py::TestExtractionFilters::test_modes"
  ];

  enabledTestPaths = [ "tests" ];
  pypaBuildFlags = [ "--config-setting=--build-option=--system-zstd" ];
  pyproject = true;
  pythonImportsCheck = [ "backports.zstd" ];

  meta = {
    description = "Backport of compression.zstd";
    homepage = "https://github.com/rogdham/backports.zstd";
    changelog = "https://github.com/rogdham/backports.zstd/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.psfl;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
