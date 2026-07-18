{
  lib,
  fetchFromGitHub,
  # optional dependencies
  azure-storage-blob,
  boto3,
  buildPythonPackage,
  dulwich,
  google-cloud-storage,
  # testing
  mock,
  pymongo,
  pytestCheckHook,
  redis,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "simplekv";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "mbr";
    repo = "simplekv";
    tag = version;
    hash = "sha256-seUGDj2q84+AjDFM1pxMLlHbe9uBgEhmqA96UHjnCmo=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
    six
  ]
  ++ optional-dependencies.git;

  build-system = [ setuptools ];

  disabledTests = [
    # Issue with fixture
    "test_concurrent_mkdir"
  ];

  optional-dependencies = {
    amazon = [ boto3 ];
    azure = [ azure-storage-blob ];
    git = [ dulwich ];
    google = [ google-cloud-storage ];
    mongodb = [ pymongo ];
    redis = [ redis ];
    /*
      Additional potential dependencies not exposed here:
        sqlalchemy: Our version is too new for simplekv
        appengine-python-standard: Not packaged in nixpkgs
    */
  };

  pyproject = true;
  pythonImportsCheck = [ "simplekv" ];

  meta = {
    description = "Simple key-value store for binary data";
    homepage = "https://github.com/mbr/simplekv";
    changelog = "https://github.com/mbr/simplekv/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      bbenne10
    ];
  };
}
