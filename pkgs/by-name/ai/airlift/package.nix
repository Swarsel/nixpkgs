{
  lib,
  docker,
  fetchPypi,
  kind,
  kubernetes-helm,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {

  pname = "airlift";
  version = "0.4.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-JcW2FXl+SrdveRmG5bD1ttf6F3LwvGZQF4ZCTpDpPa8=";
  };

  postPatch = ''
    sed -i '/argparse/d' pyproject.toml
  '';

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  buildInputs = [
    kubernetes-helm
    kind
    docker
  ];

  propagatedBuildInputs = with python3.pkgs; [
    halo
    pyyaml
    hiyapyco
    jinja2
    dotmap
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "airlift"
  ];

  pythonRelaxDeps = [
    "hiyapyco"
  ];

  meta = {
    description = "Flexible, configuration driven CLI for Apache Airflow local development";
    homepage = "https://github.com/jl178/airlift";
    changelog = "https://github.com/jl178/airlift/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jl178 ];
    mainProgram = "airlift";
  };
})
