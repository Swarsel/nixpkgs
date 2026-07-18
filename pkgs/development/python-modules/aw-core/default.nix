{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecation,
  gitUpdater,
  iso8601,
  jsonschema,
  peewee,
  platformdirs,
  poetry-core,
  pytestCheckHook,
  rfc3339-validator,
  strict-rfc3339,
  timeslot,
  tomlkit,
}:

buildPythonPackage rec {
  pname = "aw-core";
  version = "0.5.17";

  # pypi distribution doesn't include tests, so build from source instead
  src = fetchFromGitHub {
    owner = "ActivityWatch";
    repo = "aw-core";
    rev = "v${version}";
    sha256 = "sha256-bKxf+fqm+6V3JgDluKVpqq5hRL3Z+x8SHMRQmNe8vUA=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    jsonschema
    peewee
    platformdirs
    iso8601
    rfc3339-validator
    strict-rfc3339
    tomlkit
    deprecation
    timeslot
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # Fake home folder for tests that write to $HOME
    export HOME="$TMPDIR"
  '';

  pyproject = true;
  pythonImportsCheck = [ "aw_core" ];

  pythonRelaxDeps = [
    "platformdirs"
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Core library for ActivityWatch";
    homepage = "https://github.com/ActivityWatch/aw-core";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ huantian ];
    mainProgram = "aw-cli";
  };
}
