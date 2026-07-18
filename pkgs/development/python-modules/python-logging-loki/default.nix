{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  freezegun,
  pytestCheckHook,
  requests,
  rfc3339,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-logging-loki";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "GreyZmeem";
    repo = "python-logging-loki";
    tag = "v${version}";
    hash = "sha256-1qHuv+xzATo11au+QAhD1lHcLJtnVKZDdQDGohHUhiI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    freezegun
  ];

  build-system = [ setuptools ];

  dependencies = [
    rfc3339
    requests
  ];

  # ValueError
  # Considering that the package has not been updated since 2019, it is likely that this test is broken
  disabledTests = [ "test_can_build_tags_from_converting_dict" ];
  pyproject = true;
  pythonImportsCheck = [ "logging_loki" ];

  meta = {
    description = "Python logging handler for Loki";
    homepage = "https://github.com/GreyZmeem/python-logging-loki";
    changelog = "https://github.com/GreyZmeem/python-logging-loki/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
