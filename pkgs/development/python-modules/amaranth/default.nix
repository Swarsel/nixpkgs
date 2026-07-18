{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  git,
  jinja2,
  jschon,
  pdm-backend,
  # for tests
  pytestCheckHook,
  pyvcd,
  sby,
  yices,
  yosys,
}:

buildPythonPackage rec {
  pname = "amaranth";
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "amaranth-lang";
    repo = "amaranth";
    tag = "v${version}";
    hash = "sha256-hqMgyQJRz1/5C9KB3nAI2RKPZXZUl3zhfZbk9M1hTxs=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "pdm-backend~=2.3.0" "pdm-backend>=2.3.0"
  '';

  nativeBuildInputs = [ git ];

  nativeCheckInputs = [
    pytestCheckHook
    sby
    yices
    yosys
  ];

  build-system = [ pdm-backend ];

  dependencies = [
    jschon
    jinja2
    pyvcd
  ];

  disabledTestPaths = [
    # Subprocesses
    "tests/test_examples.py"
    # Verification failures
    "tests/test_lib_fifo.py"
  ];

  disabledTests = [
    "verilog"
    "test_reversible"
    "test_distance"
  ];

  pyproject = true;
  pythonImportsCheck = [ "amaranth" ];

  meta = {
    description = "Modern hardware definition language and toolchain based on Python";
    homepage = "https://amaranth-lang.org/docs/amaranth";
    changelog = "https://github.com/amaranth-lang/amaranth/blob/${src.tag}/docs/changes.rst";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      thoughtpolice
      pbsds
    ];

    mainProgram = "amaranth-rpc";
  };
}
