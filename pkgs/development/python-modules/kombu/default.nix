{
  lib,
  fetchFromGitHub,
  amqp,
  azure-identity,
  azure-servicebus,
  azure-storage-queue,
  boto3,
  buildPythonPackage,
  confluent-kafka,
  google-cloud-monitoring,
  google-cloud-pubsub,
  grpcio,
  hypothesis,
  kazoo,
  msgpack,
  packaging,
  protobuf,
  pycurl,
  pymongo,
  #, pyro4
  pytestCheckHook,
  pyyaml,
  redis,
  setuptools,
  sqlalchemy,
  tzdata,
  urllib3,
  vine,
}:

buildPythonPackage rec {
  pname = "kombu";
  version = "5.6.2";

  src = fetchFromGitHub {
    owner = "celery";
    repo = "kombu";
    tag = "v${version}";
    hash = "sha256-J0cEQsMHKethrfDVDDvIjc/iZpoCYLH9INHtgKmH9Pk=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    amqp
    packaging
    tzdata
    vine
  ];

  disabledTests = [
    # Disable pyro4 test
    "test_driver_version"
    # AssertionError: assert [call('WATCH'..., 'test-tag')] ==...
    "test_global_keyprefix_transaction"
    # Broken on latest redis-py, see https://github.com/celery/kombu/issues/2362
    "test_connparams_health_check_interval_supported"
  ];

  optional-dependencies = {
    azureservicebus = [ azure-servicebus ];

    azurestoragequeues = [
      azure-identity
      azure-storage-queue
    ];

    confluentkafka = [ confluent-kafka ];

    gcpubsub = [
      google-cloud-pubsub
      google-cloud-monitoring
      grpcio
      protobuf
    ];

    mongodb = [ pymongo ];
    msgpack = [ msgpack ];
    redis = [ redis ];
    sqlalchemy = [ sqlalchemy ];

    sqs = [
      boto3
      urllib3
      pycurl
    ];

    yaml = [ pyyaml ];
    zookeeper = [ kazoo ];
    # pyro4 doesn't support Python 3.11
    #pyro = [
    #  pyro4
    #];
  };

  pyproject = true;
  pythonImportsCheck = [ "kombu" ];

  meta = {
    description = "Messaging library for Python";
    homepage = "https://github.com/celery/kombu";
    changelog = "https://github.com/celery/kombu/blob/v${version}/Changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
