{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dramatiq,
  gevent,
  pytest-cov-stub,
  pytestCheckHook,
  redis,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dramatiq-abort";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "Flared";
    repo = "dramatiq-abort";
    tag = "v${version}";
    hash = "sha256-i5vL9yjQQambG8m6RDByr7/j8+PhDdLsai3pDrH1A4Q=";
  };

  patches = [
    # https://github.com/Flared/dramatiq-abort/pull/38
    ./dramatiq-2.0-stub-broker-fail-fast.patch
  ];

  nativeCheckInputs = [
    redis
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    dramatiq
  ];

  optional-dependencies = {
    all = lib.concatAttrValues (lib.removeAttrs optional-dependencies [ "all" ]);
    gevent = [ gevent ];
    redis = [ redis ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dramatiq_abort" ];

  meta = {
    description = "Dramatiq extension to abort message";
    homepage = "https://github.com/Flared/dramatiq-abort";
    changelog = "https://github.com/Flared/dramatiq-abort/releases/tag/v${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ tebriel ];
  };
}
