{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  unstableGitUpdater,
}:

buildPythonPackage {
  pname = "astor";
  version = "0.8.1-unstable-2024-03-30";

  src = fetchFromGitHub {
    owner = "berkerpeksag";
    repo = "astor";
    rev = "df09001112f079db54e7c5358fa143e1e63e74c4";
    hash = "sha256-VF+harl/q2yRU2yqN1Txud3YBNSeedQNw2SZNYQFsno=";
  };

  patches = [
    # https://github.com/berkerpeksag/astor/pull/233
    ./python314-compat.patch
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # https://github.com/berkerpeksag/astor/issues/196
    "test_convert_stdlib"
  ];

  pyproject = true;

  passthru.updateScript = unstableGitUpdater {
    branch = "master";
  };

  meta = {
    description = "Library for reading, writing and rewriting python AST";
    homepage = "https://github.com/berkerpeksag/astor";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nixy ];
  };
}
