{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  hypothesis,
  msgspec,
  pdm-backend,
  pydantic,
  pyhumps,
  pytest-asyncio,
  pytestCheckHook,
  quart,
}:

buildPythonPackage (finalAttrs: {
  pname = "quart-schema";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "pgjones";
    repo = "quart-schema";
    tag = finalAttrs.version;
    hash = "sha256-xrCQNGxX9CC1fOy3CT40Sdvsd94KgE1k8B5UgIWZ8kY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pydantic
    hypothesis
  ];

  preCheck = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--no-cov-on-fail" ""
  '';

  build-system = [ pdm-backend ];

  dependencies = [
    pyhumps
    quart
    msgspec
    attrs
  ];

  pyproject = true;

  pythonImportsCheck = [
    "quart"
    "quart_schema"
  ];

  meta = {
    description = "Create subcommand-based CLI programs with docopt";
    homepage = "https://github.com/abingham/docopt-subcommands";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
