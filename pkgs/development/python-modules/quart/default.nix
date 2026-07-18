{
  lib,
  fetchFromGitHub,
  # propagates
  aiofiles,
  blinker,
  buildPythonPackage,
  click,
  flask,
  # build-system
  flit-core,
  hypercorn,
  # tests
  hypothesis,
  itsdangerous,
  jinja2,
  markupsafe,
  mock,
  py,
  pydata-sphinx-theme,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  python-dotenv,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "quart";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "pallets";
    repo = "quart";
    tag = version;
    hash = "sha256-NApev3nRBS4QDMGq8++rSmK5YgeljkaVAsdezsTbZr4=";
  };

  nativeCheckInputs = [
    hypothesis
    mock
    py
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    aiofiles
    blinker
    click
    flask
    hypercorn
    itsdangerous
    jinja2
    markupsafe
    pydata-sphinx-theme
    python-dotenv
    werkzeug
  ];

  pyproject = true;
  pythonImportsCheck = [ "quart" ];

  meta = {
    description = "Async Python micro framework for building web applications";
    homepage = "https://github.com/pallets/quart/";
    changelog = "https://github.com/pallets/quart/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "quart";
  };
}
