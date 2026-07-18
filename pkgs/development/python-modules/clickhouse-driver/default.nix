{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  clickhouse-cityhash,
  cython,
  freezegun,
  lz4,
  mock,
  pytest-xdist,
  pytestCheckHook,
  pytz,
  setuptools,
  tzlocal,
  zstd,
}:

buildPythonPackage rec {
  pname = "clickhouse-driver";
  version = "0.2.10";

  # pypi source doesn't contain tests
  src = fetchFromGitHub {
    owner = "mymarilyn";
    repo = "clickhouse-driver";
    rev = version;
    hash = "sha256-veFkmXAp8b6/Npt7f1EhMfM9OKlLugKtlXS+zMHWAro=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "lz4<=3.0.1" "lz4<=4"
  '';

  nativeBuildInputs = [
    cython
    setuptools
  ];

  propagatedBuildInputs = [
    clickhouse-cityhash
    lz4
    pytz
    tzlocal
    zstd
  ];

  # most tests require `clickhouse`
  # TODO: enable tests after `clickhouse` unbroken
  doCheck = false;

  nativeCheckInputs = [
    freezegun
    mock
    pytest-xdist
    pytestCheckHook
  ];

  # remove source to prevent pytest testing source instead of the build artifacts
  # (the source doesn't contain the extension modules)
  preCheck = ''
    rm -rf clickhouse_driver
  '';

  # some test in test_buffered_reader.py doesn't seem to return
  disabledTestPaths = [ "tests/test_buffered_reader.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "clickhouse_driver" ];

  meta = {
    description = "Python driver with native interface for ClickHouse";
    homepage = "https://github.com/mymarilyn/clickhouse-driver";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ breakds ];
  };
}
