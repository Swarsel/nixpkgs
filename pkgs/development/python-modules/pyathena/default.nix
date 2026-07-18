{
  lib,
  boto3,
  botocore,
  buildPythonPackage,
  fastparquet,
  fetchPypi,
  fsspec,
  hatch-vcs,
  hatchling,
  pandas,
  pyarrow,
  python-dateutil,
  sqlalchemy,
  tenacity,
}:

buildPythonPackage rec {
  pname = "pyathena";
  version = "3.30.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AS2s9OUgXc5wW73HCogCWorq3BFLydLQrE/LEir6BFc=";
  };

  # Nearly all tests depend on a working AWS Athena instance,
  # therefore deactivating them.
  # https://github.com/laughingman7743/PyAthena/#testing
  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    boto3
    botocore
    fsspec
    tenacity
    python-dateutil
  ];

  optional-dependencies = {
    arrow = [ pyarrow ];
    fastparquet = [ fastparquet ];
    pandas = [ pandas ];
    sqlalchemy = [ sqlalchemy ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyathena" ];

  meta = {
    description = "Python DB API 2.0 (PEP 249) client for Amazon Athena";
    homepage = "https://github.com/laughingman7743/PyAthena/";
    changelog = "https://github.com/laughingman7743/PyAthena/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
