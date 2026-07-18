{
  lib,
  fetchFromGitHub,
  aiounittest,
  buildPythonPackage,
  # runtime
  cassandra-driver,
  # build
  hatchling,
  mock,
  motor,
  numpy,
  pybloomfilter3,
  pymongo,
  pytest-asyncio,
  pytest-rerunfailures,
  # check
  pytestCheckHook,
  redis,
  scipy,
}:

buildPythonPackage (finalAttrs: {
  pname = "datasketch";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "ekzhu";
    repo = "datasketch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PSSu+ymAFWSsNRaAByGuUjoDSqzkiC0mwHpuD5YVFjA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--cov-report=xml" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    cassandra-driver
    mock
    motor
    redis
    pybloomfilter3
    pymongo
    pytest-rerunfailures
    pytest-asyncio
  ];

  build-system = [ hatchling ];

  dependencies = [
    numpy
    scipy
  ];

  disabledTestPaths = [
    # these tests import mockredis, which has been abandoned for many years
    "test/test_lsh.py"
    "test/test_lshensemble.py"
  ];

  disabledTests = [
    # flaky
    "test_soft_remove_and_pop_and_clean"
  ];

  optional-dependencies = rec {
    all = cassandra ++ redis ++ experimental_aio ++ bloom;
    bloom = [ pybloomfilter3 ];
    cassandra = [ cassandra-driver ];

    experimental_aio = [
      motor
      aiounittest
    ];

    redis = [ redis ];
  };

  pyproject = true;

  meta = {
    description = "MinHash, LSH, LSH Forest, Weighted MinHash, HyperLogLog, HyperLogLog++, LSH Ensemble and HNSW";
    homepage = "https://ekzhu.com/datasketch/";
    changelog = "https://github.com/ekzhu/datasketch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jokatzke ];
  };
})
