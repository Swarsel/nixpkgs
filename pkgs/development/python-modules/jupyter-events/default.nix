{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optionals
  click,
  # build
  hatchling,
  # runtime
  jsonschema,
  packaging,
  # tests
  pytest-asyncio,
  pytest-console-scripts,
  pytestCheckHook,
  python-json-logger,
  pyyaml,
  referencing,
  rfc3339-validator,
  rfc3986-validator,
  rich,
  traitlets,
}:

buildPythonPackage rec {
  pname = "jupyter-events";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "jupyter";
    repo = "jupyter_events";
    tag = "v${version}";
    hash = "sha256-l/u0XRP6mjqXywVzRXTWSm4E5a6o2oCdOBGGzLb85Ek=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-console-scripts
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export PATH="$out/bin:$PATH"
  '';

  build-system = [ hatchling ];

  dependencies = [
    jsonschema
    packaging
    python-json-logger
    pyyaml
    referencing
    rfc3339-validator
    rfc3986-validator
    traitlets
  ]
  ++ jsonschema.optional-dependencies.format-nongpl;

  optional-dependencies = {
    cli = [
      click
      rich
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "jupyter_events" ];

  meta = {
    description = "Configurable event system for Jupyter applications and extensions";
    homepage = "https://github.com/jupyter/jupyter_events";
    changelog = "https://github.com/jupyter/jupyter_events/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    mainProgram = "jupyter-events";
    teams = [ lib.teams.jupyter ];
  };
}
