{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  python-dateutil,
  requests,
  setuptools,
  wheel,
  xdoctest,
  xxhash,
}:

buildPythonPackage rec {
  pname = "ubelt";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "Erotemic";
    repo = "ubelt";
    tag = "v${version}";
    hash = "sha256-iEKwJaOWiotyGcz1orc8z3Iqq5Va7p639ebStOA1bCo=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  nativeCheckInputs = [
    pytestCheckHook
    requests
    xdoctest
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  __darwinAllowLocalNetworking = true;

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # fail due to sandbox environment
    "CacheStamp.expired"
    "userhome"
  ];

  optional-dependencies = {
    optional = [
      numpy
      python-dateutil
      xxhash
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ubelt" ];

  meta = {
    description = "Python utility library with a stdlib like feel and extra batteries. Paths, Progress, Dicts, Downloads, Caching, Hashing: ubelt makes it easy";
    homepage = "https://github.com/Erotemic/ubelt";
    changelog = "https://github.com/Erotemic/ubelt/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
