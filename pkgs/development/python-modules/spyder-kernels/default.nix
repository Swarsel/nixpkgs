{
  lib,
  fetchFromGitHub,
  # tests
  anyio,
  buildPythonPackage,
  # dependencies
  cloudpickle,
  django,
  flaky,
  h5py,
  ipykernel,
  ipython,
  jupyter-client,
  numpy,
  pandas,
  pillow,
  polars,
  pyarrow,
  pydicom,
  pytestCheckHook,
  pythonAtLeast,
  pyxdg,
  pyzmq,
  scipy,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
  wurlitzer,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "spyder-kernels";
  version = "3.1.5";

  src = fetchFromGitHub {
    owner = "spyder-ide";
    repo = "spyder-kernels";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FdZKWtMRTLq16rULc4lQx4GywtyZ+ori2z85PgK1geM=";
  };

  nativeCheckInputs = [
    anyio
    django
    flaky
    h5py
    numpy
    pandas
    pillow
    polars
    pyarrow
    pydicom
    pytestCheckHook
    scipy
    writableTmpDirAsHomeHook
    xarray
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    cloudpickle
    ipykernel
    ipython
    jupyter-client
    pyxdg
    pyzmq
    wurlitzer
  ];

  disabledTests = [
    "test_umr_reload_modules"
    # OSError: Kernel failed to start
    "test_debug_namespace"
    "test_enter_debug_after_interruption"
    "test_global_message"
    "test_interrupt_long_sleep"
    "test_interrupt_short_loop"
    "test_matplotlib_inline"
    "test_multiprocessing"
    "test_np_threshold"
    "test_runfile"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # AttributeError: 'Frame' object has no attribute 'f_locals'. Did you mean: 'f_globals'?
    "test_functions_with_locals_in_pdb"
  ];

  pyproject = true;
  pythonImportsCheck = [ "spyder_kernels" ];

  pythonRelaxDeps = [
    "ipykernel"
  ];

  meta = {
    description = "Jupyter kernels for Spyder's console";
    homepage = "https://docs.spyder-ide.org/current/ipythonconsole.html";
    changelog = "https://github.com/spyder-ide/spyder-kernels/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/spyder-ide/spyder-kernels/releases";
  };
})
