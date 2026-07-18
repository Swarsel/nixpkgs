{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  fetchpatch,
  setuptools,
}:

buildPythonPackage rec {
  pname = "clickhouse-cityhash";
  version = "1.0.2.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-T5jvgbIfDU2tWCR76kC6/AmM9v+g7eaZiC1KQurD7Xk=";
    pname = "clickhouse_cityhash";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-DcmASvDK160IokC5OuZoXpAHKbBOReGs96SU7yW9Ncc=";
      # Cython 3.1 removed long() function.
      # https://github.com/xzkostyan/clickhouse-cityhash/pull/6
      url = "https://github.com/thevar1able/clickhouse-cityhash/commit/1109fc80e24cb44ec9ee2885e1e5cce7141c7ad8.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "Cython>=3.0,<3.1" "Cython>=3.0"
  '';

  nativeBuildInputs = [
    cython
    setuptools
  ];

  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "clickhouse_cityhash" ];

  meta = {
    description = "Python-bindings for CityHash, a fast non-cryptographic hash algorithm";
    homepage = "https://github.com/xzkostyan/python-cityhash";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ breakds ];
  };
}
