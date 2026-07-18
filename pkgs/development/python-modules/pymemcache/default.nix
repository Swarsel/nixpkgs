{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  faker,
  mock,
  pytest-cov-stub,
  pytestCheckHook,
  python-memcached,
  setuptools,
  zstd,
}:

buildPythonPackage rec {
  pname = "pymemcache";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "pinterest";
    repo = "pymemcache";
    rev = "v${version}";
    hash = "sha256-WgtHhp7lE6StoOBfSy9+v3ODe/+zUC7lGrc2S4M68+M=";
  };

  nativeCheckInputs = [
    faker
    mock
    pytest-cov-stub
    pytestCheckHook
    python-memcached
    zstd
  ];

  build-system = [ setuptools ];

  disabledTests = lib.optionals stdenv.hostPlatform.is32bit [
    # test_compressed_complex is broken on 32-bit platforms
    # this can be removed on the next version bump
    # see also https://github.com/pinterest/pymemcache/pull/480
    "test_compressed_complex"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymemcache" ];

  meta = {
    description = "Python memcached client";
    homepage = "https://pymemcache.readthedocs.io/";
    changelog = "https://github.com/pinterest/pymemcache/blob/${src.rev}/ChangeLog.rst";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
