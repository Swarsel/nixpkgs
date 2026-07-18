{
  lib,
  stdenv,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  filelock,
  flit-core,
  packaging,
  pyproject-hooks,
  pytest-mock,
  pytest-rerunfailures,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
  uv,
  virtualenv,
  wheel,
}:

buildPythonPackage rec {
  pname = "build";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "build";
    tag = version;
    hash = "sha256-Kxqqh9HfNC28CxFHzVkNVzqNM8MVkLgkaCU2jxpjceA=";
  };

  # We need to disable tests because this package is part of the bootstrap chain
  # and its test dependencies cannot be built yet when this is being built.
  doCheck = false;
  build-system = [ flit-core ];

  dependencies = [
    packaging
    pyproject-hooks
  ];

  pyproject = true;
  pythonImportsCheck = [ "build" ];
  pythonRemoveDeps = [ "importlib-metadata" ];

  passthru.tests = {
    pytest = buildPythonPackage {
      inherit src version;
      pname = "${pname}-pytest";

      nativeCheckInputs = [
        build
        filelock
        pytest-mock
        pytest-rerunfailures
        pytest-xdist
        pytestCheckHook
        setuptools
        uv
        virtualenv
        wheel
      ];

      __darwinAllowLocalNetworking = true;

      disabledTests = [
        # Tests often fail with StopIteration
        "test_isolat"
        "test_default_pip_is_never_too_old"
        "test_build"
        "test_with_get_requires"
        "test_init"
        "test_output"
        "test_wheel_metadata"
        # Tests require network access to run pip install
        "test_logging_output"
        "test_pythonpath_does_not_interfere_with_outer_pip"
        "test_requirement_installation"
        "test_verbose_logging_output"
        "test_verbose_output"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        # Expects Apple's Python and its quirks
        "test_can_get_venv_paths_with_conflicting_default_scheme"
      ];

      dontBuild = true;
      dontInstall = true;
      pyproject = false;

      pytestFlags = [
        "-Wignore::DeprecationWarning"
      ];
    };
  };

  meta = {
    description = "Simple, correct PEP517 package builder";

    longDescription = ''
      build will invoke the PEP 517 hooks to build a distribution package. It
      is a simple build tool and does not perform any dependency management.
    '';

    homepage = "https://github.com/pypa/build";
    changelog = "https://github.com/pypa/build/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.fab ];
    mainProgram = "pyproject-build";
    teams = [ lib.teams.python ];
  };
}
