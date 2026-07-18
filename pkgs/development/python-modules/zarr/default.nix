{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # gpu
  cupy,
  # dependencies
  donfig,
  # optional-dependencies
  # remote
  fsspec,
  google-crc32c,
  hatch-vcs,
  # build-system
  hatchling,
  # test
  hypothesis,
  numcodecs,
  numpy,
  numpydoc,
  packaging,
  pytest-asyncio,
  pytestCheckHook,
  # optional
  rich,
  tomlkit,
  # cli
  typer,
  typing-extensions,
  universal-pathlib,
  obstore ? null, # TODO: Package
}:

buildPythonPackage (finalAttrs: {
  pname = "zarr";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "zarr-developers";
    repo = "zarr-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WExQT/Je+esq0dv9HtPxGt7ioJgIwW8cGNuPwM+ANEc=";
  };

  # Avoid requiring pytest-benchmark - we don't care about these
  preBuild = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"--benchmark-columns", "min,mean,stddev,outliers,rounds,iterations",' "" \
      --replace-fail '"--benchmark-disable",' "" \
  '';

  nativeCheckInputs = [
    hypothesis
    numpydoc
    pytest-asyncio
    pytestCheckHook
    tomlkit
  ]
  ++ finalAttrs.finalPackage.passthru.optional-dependencies.cli;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    donfig
    numcodecs
    google-crc32c
    numpy
    packaging
    typing-extensions
  ];

  disabledTestPaths = [
    # requires uv and then fails at setting up python envs
    "tests/test_examples.py::test_scripts_can_run[script_path0]"
    # Requires zarr==2.x to generate zarr stores for the tests
    "tests/test_regression"
    # See also preBuild above.
    "tests/benchmarks/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "zarr" ];

  passthru = {
    optional-dependencies = {
      cli = [
        typer
      ];

      gpu = [
        cupy
      ];

      optional = [
        rich
        universal-pathlib
      ];

      remote = [
        fsspec
        obstore
      ];
    };
  };

  meta = {
    description = "Implementation of chunked, compressed, N-dimensional arrays for Python";
    homepage = "https://github.com/zarr-developers/zarr";
    changelog = "https://github.com/zarr-developers/zarr-python/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
