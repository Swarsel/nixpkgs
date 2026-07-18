{
  lib,
  fetchFromGitHub,
  aiohttp,
  boto3,
  botocore,
  buildPythonPackage,
  loguru,
  pyquery,
  requests,
  setuptools,
  unasync,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyhive-integration";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "Pyhass";
    repo = "Pyhiveapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8Lv41xgkwVpisdJpzhhBxdAG3VdKYazmbvl3V7lAjYA=";
  };

  postBuild = ''
    # pyhiveapi accesses $HOME upon importing
    export HOME=$TMPDIR
  '';

  # tests are not functional yet
  doCheck = false;

  build-system = [
    setuptools
    unasync
  ];

  dependencies = [
    boto3
    botocore
    requests
    aiohttp
    pyquery
    loguru
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyhiveapi" ];
  pythonRemoveDeps = [ "pre-commit" ];

  meta = {
    description = "Python library to interface with the Hive API";
    homepage = "https://github.com/Pyhass/Pyhiveapi";
    changelog = "https://github.com/Pyhass/Pyhiveapi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
