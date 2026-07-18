{
  lib,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  buildPythonPackage,
  gitMinimal,
  # dependencies
  packaging,
  # build-system
  poetry-core,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "dunamai";
  version = "1.25.0";

  src = fetchFromGitHub {
    owner = "mtkennerly";
    repo = "dunamai";
    tag = "v${version}";
    hash = "sha256-kPOEhJwsSzGea7fS5y5tbAvzZZ+OxIyjpYpS6i++rHE=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    gitMinimal
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    git config --global user.email "nobody@example.com"
    git config --global user.name "Nobody"
  '';

  build-system = [ poetry-core ];
  dependencies = [ packaging ];

  disabledTests = [
    # clones from github.com
    "test__version__from_git__shallow"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dunamai" ];

  meta = {
    description = "Dynamic version generation";
    homepage = "https://github.com/mtkennerly/dunamai";
    changelog = "https://github.com/mtkennerly/dunamai/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jmgilman ];
    mainProgram = "dunamai";
  };
}
