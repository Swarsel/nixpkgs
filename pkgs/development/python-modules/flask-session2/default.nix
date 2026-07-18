{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cachelib,
  # tests
  elasticsearch,
  flask,
  flask-sqlalchemy,
  peewee,
  # build-system
  poetry-core,
  pymemcache,
  pymongo,
  pytestCheckHook,
  pytz,
  redis,
  redisTestHook,
}:

buildPythonPackage rec {
  pname = "flask-session2";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "christopherpickering";
    repo = "flask-session2";
    tag = "v${version}";
    hash = "sha256-kxUuEirUG/jZlygKyQy2Sm7hmB331K2q8vBmcIbp7/s=";
  };

  nativeCheckInputs = [
    elasticsearch
    flask-sqlalchemy
    peewee
    pymemcache
    pymongo
    pytestCheckHook
    redis
    redisTestHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    cachelib
    flask
    pytz
  ];

  disabledTests = [
    "test_elasticsearch_session"
    "test_flasksqlalchemy_session"
    "test_flasksqlalchemy_session_with_signer"
    "test_memcached_session"
    "test_mongodb_session"
    "test_session_use_signer"
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_session" ];

  pythonRelaxDeps = [
    "cachelib"
    "flask"
    "pytz"
  ];

  meta = {
    description = "Flask extension that adds support for server-side sessions";
    homepage = "https://github.com/christopherpickering/flask-session2";
    changelog = "https://github.com/christopherpickering/flask-session2/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
