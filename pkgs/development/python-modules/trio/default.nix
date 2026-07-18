{
  lib,
  fetchFromGitHub,
  # tests
  astor,
  # dependencies
  attrs,
  buildPythonPackage,
  idna,
  jedi,
  outcome,
  pyopenssl,
  pytest-trio,
  pytestCheckHook,
  pythonOlder,
  pyyaml,
  # build-system
  setuptools,
  sniffio,
  sortedcontainers,
  trustme,
}:

let
  # escape infinite recursion with pytest-trio
  pytest-trio' = (pytest-trio.override { trio = null; }).overrideAttrs {
    doCheck = false;
    # `pythonRemoveDeps` is not working properly
    dontCheckRuntimeDeps = true;
    pythonImportsCheck = [ ];
  };
in
buildPythonPackage rec {
  pname = "trio";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "python-trio";
    repo = "trio";
    tag = "v${version}";
    hash = "sha256-kZKP5TFg9M+NCx9V9B0qNbGiwZtBPtgVKgZYjX5w1ok=";
  };

  nativeCheckInputs = [
    astor
    pyopenssl
    pytestCheckHook
    pytest-trio'
    pyyaml
    trustme
  ]
  # jedi has no compatibility with python 3.14 yet
  # https://github.com/davidhalter/jedi/issues/2064
  ++ lib.optional (pythonOlder "3.14") jedi;

  preCheck = ''
    export HOME=$TMPDIR
    # $out is first in path which causes "import file mismatch"
    PYTHONPATH=$PWD/src:$PYTHONPATH
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    attrs
    idna
    outcome
    sniffio
    sortedcontainers
  ];

  disabledTestPaths = [
    # linters
    "src/trio/_tests/tools/test_gen_exports.py"
  ];

  # It appears that the build sandbox doesn't include /etc/services, and these tests try to use it.
  disabledTests = [
    "getnameinfo"
    "SocketType_resolve"
    "getprotobyname"
    "waitpid"
    "static_tool_sees_all_symbols"
    # tests pytest more than python
    "fallback_when_no_hook_claims_it"
    # requires mypy
    "test_static_tool_sees_class_members"
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  meta = {
    description = "Async/await-native I/O library for humans and snake people";
    homepage = "https://github.com/python-trio/trio";
    changelog = "https://github.com/python-trio/trio/blob/${src.tag}/docs/source/history.rst";

    license = with lib.licenses; [
      mit
      asl20
    ];
  };
}
