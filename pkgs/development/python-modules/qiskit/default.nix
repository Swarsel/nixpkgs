{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  dill,
  libiconv,
  matplotlib,
  numpy,
  pillow,
  pydot,
  pylatexenc,
  python-constraint,
  rustPlatform,
  rustc,
  rustworkx,
  scipy,
  seaborn,
  setuptools,
  setuptools-rust,
  stevedore,
  symengine,
  sympy,
  typing-extensions,
  z3-solver,
}:

buildPythonPackage rec {
  pname = "qiskit";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit";
    tag = version;
    hash = "sha256-Y5JgapafP3lxR7PMNB7+yDoM6vFvSoMZMrpOE2jeemU=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src pname version;
    hash = "sha256-skyZSoYO9XiwQGkgSxRCB3N0+XgDMM5IM9o6KfSG35k=";
  };

  dependencies = [
    dill
    numpy
    rustworkx
    scipy
    stevedore
    typing-extensions
  ];

  optional-dependencies = {
    crosstalk-pass = [
      z3-solver
    ];

    csp-layout-pass = [
      python-constraint
    ];

    qpy-compat = [
      symengine
      sympy
    ];

    visualization = [
      matplotlib
      pillow
      pydot
      pylatexenc
      seaborn
      sympy
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "qiskit"
    "qiskit.circuit"
    "qiskit.providers.basic_provider"
  ];

  meta = {
    description = "Software for developing quantum computing programs";

    longDescription = ''
      Open-source SDK for working with quantum computers at the level of
      extended quantum circuits, operators, and primitives.
    '';

    homepage = "https://www.ibm.com/quantum/qiskit";
    changelog = "https://docs.quantum.ibm.com/api/qiskit/release-notes";
    license = lib.licenses.asl20;
    maintainers = [ ];
    downloadPage = "https://github.com/QISKit/qiskit/releases";
  };
}
