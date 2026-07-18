{
  lib,
  # dependencies
  aiohttp,
  alembic,
  buildPythonPackage,
  cryptography,
  docker,
  fetchPypi,
  flask,
  flask-cors,
  graphene,
  gunicorn,
  huey,
  matplotlib,
  mlflow-skinny,
  mlflow-tracing,
  numpy,
  pandas,
  pyarrow,
  scikit-learn,
  scipy,
  skops,
  sqlalchemy,
}:

buildPythonPackage (finalAttrs: {
  pname = "mlflow";
  version = "3.14.0";

  # We build from the PyPI wheel rather than fetchFromGitHub, because the mlflow-server
  # JS UI is absent from GitHub but provided in the wheel.
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-2/d/fNtbXA7Fm0ZxxhcwsbkUtN/3ookuJnpUfLVFT1Y=";
    dist = "py3";
    format = "wheel";
    pname = "mlflow";
    python = "py3";
  };

  # I (@GaetanLepage) gave up at enabling tests:
  # - They require a lot of dependencies (some unpackaged);
  # - Many errors occur at collection time;
  # - Most (all ?) tests require internet access anyway.
  doCheck = false;

  # Nix-wrapped python populates sys.path via NIX_PYTHONPATH/site hooks,
  # but PYTHONPATH stays unset in os.environ. mlflow spawns the server
  # in a subprocess with a curated env, so without this patch the child
  # interpreter cannot import uvicorn / mlflow itself.
  postInstall = ''
    patch -p1 -d "$out/lib/python"*/site-packages < ${./subprocess-pythonpath.patch}
  '';

  __structuredAttrs = true;

  dependencies = [
    aiohttp
    alembic
    cryptography
    docker
    flask
    flask-cors
    graphene
    gunicorn
    huey
    matplotlib
    mlflow-skinny
    mlflow-tracing
    numpy
    pandas
    pyarrow
    scikit-learn
    scipy
    skops
    sqlalchemy
  ];

  format = "wheel";
  pythonImportsCheck = [ "mlflow" ];

  pythonRelaxDeps = [
    "cryptography"
  ];

  meta = {
    description = "Open source platform for the machine learning lifecycle";
    homepage = "https://github.com/mlflow/mlflow";
    changelog = "https://github.com/mlflow/mlflow/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    # Build from wheel which contains pure Python and pre-built JS bundle.
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [
      GaetanLepage
      gquetel
    ];

    mainProgram = "mlflow";
  };
})
