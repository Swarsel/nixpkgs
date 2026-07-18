{
  lib,
  stdenv,
  buildPythonPackage,
  cargo,
  fetchPypi,
  maturin,
  python,
  replaceVars,
  rustPlatform,
  rustc,
  semantic-version,
  setuptools,
  setuptools-rust,
  setuptools-scm,
  targetPackages,
}:
buildPythonPackage rec {
  pname = "setuptools-rust";
  version = "1.12.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2UqT8Ml3UcFwFFZfB73DJL7kXTls0buoPY56+SuUXww=";
    pname = "setuptools_rust";
  };

  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    semantic-version
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "setuptools_rust" ];

  # integrate the setup hook to set up the build environment for cross compilation
  # this hook is automatically propagated to consumers using setuptools-rust as build-system
  #
  # Only include the setup hook if python.pythonOnTargetForTarget is not empty.
  # python.pythonOnTargetForTarget is not always available, for example in
  # pkgsLLVM.python3.pythonOnTargetForTarget. cross build with pkgsLLVM should not be affected.
  setupHook =
    if python.pythonOnTargetForTarget == { } then
      null
    else
      replaceVars ./setuptools-rust-hook.sh {
        cargoBuildTarget = stdenv.targetPlatform.rust.rustcTargetSpec;
        cargoLinkerVar = stdenv.targetPlatform.rust.cargoEnvVarTarget;
        pyLibDir = "${python.pythonOnTargetForTarget}/lib/${python.pythonOnTargetForTarget.libPrefix}";
        targetLinker = "${targetPackages.stdenv.cc}/bin/${targetPackages.stdenv.cc.targetPrefix}cc";
      };

  passthru.tests = {
    pyo3 = maturin.tests.pyo3.override {
      nativeBuildInputs = [
        setuptools-rust
      ]
      ++ [
        rustPlatform.cargoSetupHook
        cargo
        rustc
      ];

      preConfigure = ''
        # sourceRoot puts Cargo.lock in the wrong place due to the
        # example setup.
        cd examples/word-count
      '';

      buildAndTestSubdir = null;
    };
  };

  meta = {
    description = "Setuptools plugin for Rust support";
    homepage = "https://github.com/PyO3/setuptools-rust";
    changelog = "https://github.com/PyO3/setuptools-rust/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
