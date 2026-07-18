{
  lib,
  stdenv,
  fetchFromCodeberg,
  lctime,
  ngspice,
  python3Packages,
  runCommand,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "lctime";
  version = "0.0.28";

  src = fetchFromCodeberg {
    owner = "librecell";
    repo = "lctime";
    tag = finalAttrs.version;
    hash = "sha256-Td56NtqcI8763hw/XVxLP7+qExraapN9ULD3ZolfR6M=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    ngspice
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    joblib
    klayout
    liberty-parser
    networkx
    numpy
    scipy
    sympy
  ];

  disabledTestPaths = [
    # hangs indefinitely
    "src/lctime/characterization/test_ngspice_subprocess.py::test_ngspice_interactive_simple"
    "src/lctime/characterization/test_ngspice_subprocess.py::test_ngspice_subprocess_class"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # causes python to abort
    "src/lctime/characterization/test_ngspice_subprocess.py::test_simple_simulation"
    # broken pipe
    "src/lctime/characterization/test_ngspice_subprocess.py::test_interactive_subprocess"
  ];

  enabledTestPaths = [
    "src/lctime/*/*.py"
  ];

  optional-dependencies.debug = with python3Packages; [ matplotlib ];
  pyproject = true;

  pythonImportsCheck = [
    "lctime"
  ];

  passthru = {
    tests =
      runCommand "lctime-tests"
        {
          nativeBuildInputs = [
            lctime
            ngspice
            writableTmpDirAsHomeHook
          ];
        }
        ''
          cd "$HOME"

          cp -R "${finalAttrs.src}/tests/"* .
          patchShebangs *.sh

          mkdir -p $out
          ./run_tests.sh &> $out/result.log
        '';
  };

  meta = {
    description = "Characterization tool for CMOS digital standard-cells";
    homepage = "https://codeberg.org/librecell/lctime";
    changelog = "https://codeberg.org/librecell/lctime/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      agpl3Plus
      asl20
      cc-by-sa-40
      cc0
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "lctime";
    teams = with lib.teams; [ ngi ];
  };
})
