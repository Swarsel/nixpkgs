{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  monarchmoneycommunity,
  pytestCheckHook,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "typedmonarchmoney";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "jeeftor";
    repo = "monarchmoney-typed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tx5JxHAJeNWLzCSAXOvb2+QsS8PU5hK28141BnooZps=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    monarchmoneycommunity
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "typedmonarchmoney" ];
  pythonRelaxDeps = [ "monarchmoneycommunity" ];

  meta = {
    description = "Typed wrapper around the Monarch Money API";
    homepage = "https://github.com/jeeftor/monarchmoney-typed";
    changelog = "https://github.com/jeeftor/monarchmoney-typed/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
