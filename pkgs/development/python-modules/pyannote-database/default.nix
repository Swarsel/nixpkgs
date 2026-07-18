{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  # dependencies
  pandas,
  pyannote-core,
  # tests
  pytestCheckHook,
  pyyaml,
  typer,
}:

buildPythonPackage rec {
  pname = "pyannote-database";
  version = "6.1.1";

  src = fetchFromGitHub {
    owner = "pyannote";
    repo = "pyannote-database";
    tag = version;
    hash = "sha256-72H1tVLtDSYHAgjHWmI7pPQhKGchHz5VP0eRU6NRj2g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    $out/bin/pyannote-database --help
  '';

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    pandas
    pyannote-core
    pyyaml
    # Imported in pyannote/database/cli.py
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyannote.database" ];

  meta = {
    description = "Reproducible experimental protocols for multimedia (audio, video, text) database";
    homepage = "https://github.com/pyannote/pyannote-database";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "pyannote-database";
  };
}
