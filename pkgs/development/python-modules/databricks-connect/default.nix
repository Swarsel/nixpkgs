{
  lib,
  buildPythonPackage,
  fetchPypi,
  jdk8,
  py4j,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "databricks-connect";
  version = "11.3.40";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rSuW/6fSro1pAxDj2tZ+EYvO0zf0yCWXNaS9Ls7xJfw=";
  };

  # requires network access
  doCheck = false;

  preFixup = ''
    substituteInPlace "$out/bin/find-spark-home" \
      --replace-fail find_spark_home.py .find_spark_home.py-wrapped
  '';

  build-system = [ setuptools ];

  dependencies = [
    py4j
    six
    jdk8
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyspark"
    "six"
    "py4j"
  ];

  pythonRelaxDeps = [ "py4j" ];
  sourceRoot = ".";

  meta = {
    description = "Client for connecting to remote Databricks clusters";
    homepage = "https://pypi.org/project/databricks-connect";
    license = lib.licenses.databricks;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ kfollesdal ];
  };
}
