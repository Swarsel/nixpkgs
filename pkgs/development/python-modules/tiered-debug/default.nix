{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "tiered-debug";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "untergeek";
    repo = "tiered-debug";
    tag = "v${version}";
    hash = "sha256-lGt2cnT5Pjb87msgnDawn2gg2VtWXwniHM1wTjHU/x4=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  disabledTests = [
    # AssertionError
    "test_add_handler"
    "test_log_with_default_stacklevel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tiered_debug" ];

  meta = {
    description = "Python logging helper module that allows for multiple tiers of debug logging";
    homepage = "https://github.com/untergeek/tiered-debug";
    changelog = "https://github.com/untergeek/tiered-debug/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
