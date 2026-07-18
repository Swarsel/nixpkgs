{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pymongo,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pymongo-inmemory";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "kaizendorks";
    repo = "pymongo_inmemory";
    tag = "v${version}";
    hash = "sha256-iYUU2XoTEfgUm+816wHveu6dPEo6nzhlZNXyuRw42T0=";
  };

  postPatch = ''
    # move cache location from nix store to home
    substituteInPlace pymongo_inmemory/context.py \
      --replace-fail \
        'CACHE_FOLDER = path.join(path.dirname(__file__), "..", ".cache")' \
        'CACHE_FOLDER = os.environ.get("XDG_CACHE_HOME", os.environ["HOME"] + "/.cache") + "/pymongo-inmemory"'

    # fix a broken assumption arising from the above fix
    substituteInPlace pymongo_inmemory/_utils.py \
      --replace-fail \
        'os.mkdir(current_path)' \
        'os.makedirs(current_path)'
  '';

  nativeBuildInputs = [ poetry-core ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME="$(mktemp -d)"
  '';

  dependencies = [ pymongo ];

  disabledTestPaths = [
    # new test with insufficient monkey patching, try to remove on next bump
    "tests/unit/test_mongod.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymongo_inmemory" ];

  meta = {
    description = "Mongo mocking library with an ephemeral MongoDB running in memory";
    homepage = "https://github.com/kaizendorks/pymongo_inmemory";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
