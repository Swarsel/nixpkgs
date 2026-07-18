{
  lib,
  fetchFromGitHub,
  bitarray,
  buildPythonPackage,
  dill,
  diskcache,
  hiredis,
  hypothesis,
  pytest,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-rerunfailures,
  pytestCheckHook,
  redis,
  setuptools,
  xxhash,
}:

buildPythonPackage rec {
  pname = "cashews";
  version = "7.5.0";

  src = fetchFromGitHub {
    owner = "Krukov";
    repo = "cashews";
    tag = version;
    hash = "sha256-GQObsWTCAKuYCyHZVd1wDzhvyYK5Xw1z1QazLuAP3Jg=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest
    pytest-asyncio
    pytest-cov-stub
    pytest-rerunfailures
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTests = [
    # these tests require too many dependencies
    "redis"
    "diskcache"
    "integration"
  ];

  optional-dependencies = {
    dill = [ dill ];
    diskcache = [ diskcache ];
    redis = [ redis ];

    speedup = [
      bitarray
      hiredis
      xxhash
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cashews" ];

  meta = {
    description = "Cache tools with async power";
    homepage = "https://github.com/Krukov/cashews/";
    changelog = "https://github.com/Krukov/cashews/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
