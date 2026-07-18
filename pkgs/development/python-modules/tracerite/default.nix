{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  html5tagger,
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "tracerite";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "sanic-org";
    repo = "tracerite";
    tag = "v${version}";
    hash = "sha256-UXIQc5rXVaZuZj5xu2X9H38vKWAM+AoKrKfudovUhwA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    beautifulsoup4
    numpy
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    html5tagger
  ];

  disabledTestPaths = [
    # requiring torch to test tensor rendering in tracebacks is too expensive
    "tests/test_inspector_torch.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tracerite" ];

  meta = {
    description = "Tracebacks for Humans in Jupyter notebooks";
    homepage = "https://github.com/sanic-org/tracerite";
    changelog = "https://github.com/sanic-org/tracerite/releases/tag/${src.tag}";

    # See https://github.com/sanic-org/tracerite/issues/13
    license = with lib.licenses; [
      mit
      publicDomain
      unlicense
    ];

    maintainers = with lib.maintainers; [ p0lyw0lf ];
  };
}
