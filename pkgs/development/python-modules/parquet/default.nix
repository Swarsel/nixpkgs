{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  pytestCheckHook,
  python-snappy,
  setuptools,
  thriftpy2,
}:

buildPythonPackage rec {
  pname = "parquet";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "jcrobak";
    repo = "parquet-python";
    tag = "v${version}";
    hash = "sha256-WVDffYKGsyepK4w1d4KUUMmxB6a6ylTbJvG79Bt5G6o=";
  };

  patches = [
    # Refactor deprecated unittest aliases, https://github.com/jcrobak/parquet-python/pull/83
    (fetchpatch {
      hash = "sha256-4awxlzman/YMfOz1WYNR+mVn1ixGku9sqlaMJ1QITYs=";
      name = "unittest-aliases.patch";
      url = "https://github.com/jcrobak/parquet-python/commit/746bebd1e84d8945a3491e1ae5e44102ff534592.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    python-snappy
    thriftpy2
  ];

  disabledTestPaths = [
    # Test is outdated
    "test/test_read_support.py"
  ];

  disabledTests = [
    # Fails with AttributeError
    "test_bson"
    "testFromExample"
  ];

  pyproject = true;
  pythonImportsCheck = [ "parquet" ];

  meta = {
    description = "Python implementation of the parquet columnar file format";
    homepage = "https://github.com/jcrobak/parquet-python";
    changelog = "https://github.com/jcrobak/parquet-python/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "parquet";
  };
}
