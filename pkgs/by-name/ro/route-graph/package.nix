{
  lib,
  fetchFromGitHub,
  graphviz,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "route-graph";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "audius";
    repo = "route-graph";
    tag = finalAttrs.version;
    hash = "sha256-aLTzej4YtKkQE5q8LKxIBe+aqrjwrG+2pbonzlWhLvU=";
  };

  propagatedBuildInputs = [
    graphviz
  ]
  ++ (with python3.pkgs; [
    scapy
    typer
    typing-extensions
  ]);

  nativeCheckInputs = with python3.pkgs; [
    pytest-mock
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "route_graph" ];

  pythonRelaxDeps = [
    "typer"
    "typing-extensions"
  ];

  meta = {
    description = "CLI tool for creating graphs of routes";
    homepage = "https://github.com/audius/route-graph";
    changelog = "https://github.com/audius/route-graph/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "route-graph";
  };
})
