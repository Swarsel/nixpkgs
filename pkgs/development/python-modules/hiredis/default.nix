{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "hiredis";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "redis";
    repo = "hiredis-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TXhl9ny6hdd4n/hHfTAL0ewGcnjZ1vvNwovklSgzkKk=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf hiredis
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "hiredis" ];

  meta = {
    description = "Wraps protocol parsing code in hiredis, speeds up parsing of multi bulk replies";
    homepage = "https://github.com/redis/hiredis-py";
    changelog = "https://github.com/redis/hiredis-py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.redis ];
  };
})
