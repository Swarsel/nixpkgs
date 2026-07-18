{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  boto3,
  buildPythonPackage,
  cachelib,
  # dependencies
  flask,
  flask-sqlalchemy,
  # build-system
  flit-core,
  memcachedTestHook,
  msgspec,
  pymemcache,
  pymongo,
  pytestCheckHook,
  python-memcached,
  redis,
  redisTestHook,
}:

buildPythonPackage rec {
  pname = "flask-session";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "flask-session";
    tag = version;
    hash = "sha256-QLtsM0MFgZbuLJPLc5/mUwyYc3bYxildNKNxOF8Z/3Y=";
  };

  # Hang indefinitely
  doCheck = !(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64);

  nativeCheckInputs = [
    flask-sqlalchemy
    memcachedTestHook
    pytestCheckHook
    redis
    redisTestHook
    pymongo
    pymemcache
    python-memcached
    boto3
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ flit-core ];

  dependencies = [
    cachelib
    flask
    msgspec
  ];

  disabledTestPaths = [ "tests/test_dynamodb.py" ];

  disabledTests = [
    # unfree
    "test_mongo_default"
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_session" ];

  meta = {
    description = "Flask extension that adds support for server-side sessions";
    homepage = "https://github.com/pallets-eco/flask-session";
    changelog = "https://github.com/pallets-eco/flask-session/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ zhaofengli ];
  };
}
