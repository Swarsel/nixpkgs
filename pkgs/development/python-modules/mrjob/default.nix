{
  lib,
  fetchFromGitHub,
  # optionals
  boto3,
  botocore,
  buildPythonPackage,
  # propagates
  distutils,
  google-cloud-dataproc,
  google-cloud-logging,
  google-cloud-storage,
  # tests
  pyspark,
  python-rapidjson,
  pythonAtLeast,
  pyyaml,
  # build-system
  setuptools,
  simplejson,
  standard-pipes,
  ujson,
  unittestCheckHook,
  warcio,
}:

buildPythonPackage rec {
  pname = "mrjob";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "Yelp";
    repo = "mrjob";
    tag = "v${version}";
    hash = "sha256-Yp4yUx6tkyGB622I9y+AWK2AkIDVGKQPMM+LtB/M3uo=";
  };

  doCheck = false; # failing tests

  nativeCheckInputs = [
    pyspark
    unittestCheckHook
    warcio
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
  ];

  dependencies = [
    distutils
    pyyaml
    standard-pipes
  ];

  optional-dependencies = {
    aws = [
      boto3
      botocore
    ];

    google = [
      google-cloud-dataproc
      google-cloud-logging
      google-cloud-storage
    ];

    rapidjson = [ python-rapidjson ];
    simplejson = [ simplejson ];
    ujson = [ ujson ];
  };

  pyproject = true;
  unittestFlagsArray = [ "-v" ];

  meta = {
    description = "Run MapReduce jobs on Hadoop or Amazon Web Services";
    homepage = "https://github.com/Yelp/mrjob";
    changelog = "https://github.com/Yelp/mrjob/blob/v${version}/CHANGES.txt";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
