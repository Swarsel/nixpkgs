{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  freezegun,
  hatch-fancy-pypi-readme,
  hatch-vcs,
  hatchling,
  pydantic,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-ulid";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "mdomke";
    repo = "python-ulid";
    tag = version;
    hash = "sha256-13yGd6vYnwzTi+KGJgoQ/z6Cy67FKVC4popaj2uPOlQ=";
  };

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ]
  ++ optional-dependencies.pydantic;

  build-system = [
    hatch-fancy-pypi-readme
    hatch-vcs
    hatchling
  ];

  optional-dependencies = {
    pydantic = [ pydantic ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ulid" ];

  meta = {
    description = "ULID implementation for Python";
    homepage = "https://github.com/mdomke/python-ulid";
    changelog = "https://github.com/mdomke/python-ulid/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    mainProgram = "ulid";
  };
}
