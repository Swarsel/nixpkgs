{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  jsonschema,
  pytestCheckHook,
  rpds-py,
  typing-extensions,
}:

let
  self = buildPythonPackage rec {
    pname = "referencing";
    version = "0.37.0";

    src = fetchFromGitHub {
      owner = "python-jsonschema";
      repo = "referencing";
      tag = "v${version}";
      hash = "sha256-4e06rzvIOyWAgkpzAisc4uUK8pWshDZiQ6qpvJCq3GY=";
      fetchSubmodules = true;
    };

    # Avoid infinite recursion with jsonschema
    doCheck = false;

    nativeCheckInputs = [
      jsonschema
      pytestCheckHook
    ];

    build-system = [
      hatch-vcs
      hatchling
    ];

    dependencies = [
      attrs
      rpds-py
      typing-extensions
    ];

    pyproject = true;
    pythonImportsCheck = [ "referencing" ];
    passthru.tests.referencing = self.overridePythonAttrs { doCheck = true; };

    meta = {
      description = "Cross-specification JSON referencing";
      homepage = "https://github.com/python-jsonschema/referencing";
      changelog = "https://github.com/python-jsonschema/referencing/releases/tag/${src.tag}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ fab ];
    };
  };
in
self
