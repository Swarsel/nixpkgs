{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  interegular,
  poetry-core,
  pydantic,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "lm-format-enforcer";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "noamgat";
    repo = "lm-format-enforcer";
    tag = "v${version}";
    hash = "sha256-aUZo7Nlk5A9SRyQFFGhy3LAJO29ygRFwNC4WbRuXvYE=";
  };

  doCheck = false; # most tests require internet access
  build-system = [ poetry-core ];

  dependencies = [
    interegular
    pydantic
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "lmformatenforcer" ];

  meta = {
    description = "Enforce the output format (JSON Schema, Regex etc) of a language model";
    homepage = "https://github.com/noamgat/lm-format-enforcer";
    changelog = "https://github.com/noamgat/lm-format-enforcer/releases/tag/${src.tag}";
    license = lib.licenses.mit;
  };
}
