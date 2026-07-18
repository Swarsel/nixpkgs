{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mako,
  parse,
  parse-type,
  poetry-core,
  pytest,
  pytest7CheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pytest-bdd";
  version = "7.1.2";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-bdd";
    tag = version;
    hash = "sha256-PC4VSsUU5qEFp/C/7OTgHINo8wmOo0w2d1Hpe0EnFzE=";
  };

  buildInputs = [ pytest ];
  # requires an update for pytest 8.4 compat
  nativeCheckInputs = [ pytest7CheckHook ];

  preCheck = ''
    export PATH=$PATH:$out/bin
  '';

  build-system = [ poetry-core ];

  dependencies = [
    mako
    parse
    parse-type
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_bdd" ];

  meta = {
    description = "BDD library for the pytest";
    homepage = "https://github.com/pytest-dev/pytest-bdd";
    changelog = "https://github.com/pytest-dev/pytest-bdd/blob/${version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jm2dev ];
    mainProgram = "pytest-bdd";
  };
}
