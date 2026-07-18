{
  lib,
  buildPythonPackage,
  fetchPypi,
  # optional-dependencies
  googleapis-common-protos,
  graphviz,
  grpcio,
  grpcio-status,
  numpy,
  pandas,
  # dependencies
  py4j,
  pyarrow,
  # build-system
  setuptools,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyspark";
  version = "4.1.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-+l1hWfcA0JkKB/T2LfG3RJQB3M7pzX1dbfiVdTCEFgI=";
  };

  # pypandoc is broken with pandoc2, so we just lose docs.
  postPatch = ''
    sed -i "s/'pypandoc'//" setup.py
  '';

  # Tests assume running spark instance
  doCheck = false;

  postFixup = ''
    # find_python_home.py has been wrapped as a shell script
    substituteInPlace $out/bin/find-spark-home \
        --replace 'export SPARK_HOME=$($PYSPARK_DRIVER_PYTHON "$FIND_SPARK_HOME_PYTHON_SCRIPT")' \
                  'export SPARK_HOME=$("$FIND_SPARK_HOME_PYTHON_SCRIPT")'
    # patch PYTHONPATH in pyspark so that it properly looks at SPARK_HOME
    substituteInPlace $out/bin/pyspark \
        --replace 'export PYTHONPATH="''${SPARK_HOME}/python/:$PYTHONPATH"' \
                  'export PYTHONPATH="''${SPARK_HOME}/..:''${SPARK_HOME}/python/:$PYTHONPATH"'
  '';

  build-system = [ setuptools ];
  dependencies = [ py4j ];

  optional-dependencies = {
    connect = [
      pandas
      pyarrow
      grpcio
      grpcio-status
      googleapis-common-protos
      zstandard
      graphviz
    ];

    ml = [ numpy ];
    mllib = [ numpy ];

    pandas_on_spark = [
      pandas
      pyarrow
    ];

    pipelines =
      finalAttrs.passthru.optional-dependencies.connect ++ finalAttrs.passthru.optional-dependencies.sql;

    sql = [
      pandas
      pyarrow
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyspark" ];

  meta = {
    description = "Python bindings for Apache Spark";
    homepage = "https://github.com/apache/spark/tree/master/python";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [
      sarahec
      shlevy
    ];
  };
})
