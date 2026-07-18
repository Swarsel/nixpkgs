{
  lib,
  fetchFromGitHub,
  aioesphomeapi,
  buildPythonPackage,
  cargo,
  psutil,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  setuptools-scm,
  socat,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "serialx";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "puddly";
    repo = "serialx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/Bx8TnO3h+Pk/Tg5YSYO96cK5PfJVwqRG0qdLJntNpQ=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
  ];

  nativeCheckInputs = [
    psutil
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    socat
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-rust
    setuptools-scm
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-mI/6Buuk0VMofcD2LmE3+FpZhISAMzSYxe2IDC2iyAE=";
  };

  dependencies = [
    typing-extensions
  ];

  disabledTests = [
    # tries to access /sys/class/tty in sandbox
    "test_compat_tools_module"
    # connects to 192.0.2.1
    "test_async_socket_connect_timeout"
    # racy
    "test_sync_readexactly_total_timeout"
    "test_sync_read_until_total_timeout"
    "test_sync_readonly_partial_timeout"
  ];

  optional-dependencies.esphome = lib.optionals (pythonAtLeast "3.14") [
    aioesphomeapi
  ];

  pyproject = true;
  pythonImportsCheck = [ "serialx" ];

  meta = {
    description = "Serial library with native async support for Windows and POSIX";
    homepage = "https://github.com/puddly/serialx";
    changelog = "https://github.com/puddly/serialx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
