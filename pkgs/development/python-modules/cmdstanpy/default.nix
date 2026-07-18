{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cmdstan,
  fetchpatch,
  numpy,
  pandas,
  pytestCheckHook,
  replaceVars,
  setuptools,
  stanio,
  tqdm,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "cmdstanpy";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "stan-dev";
    repo = "cmdstanpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XVviGdJ41mcjCscL3jvcpHi6zMREHsuShGHpnMQX6V8=";
  };

  patches = [
    (replaceVars ./use-nix-cmdstan-path.patch {
      cmdstan = "${cmdstan}/opt/cmdstan";
    })
    # Fix tests for cmdstan 2.39.0
    (fetchpatch {
      hash = "sha256-BZcJiRAluItsfzvGJ2yJVDHuUp92AI19x7d06wRGzY4=";
      url = "https://github.com/stan-dev/cmdstanpy/commit/5ef72db67660b8fb0ea0ba25bef9667e88aafc5f.patch";
    })
    (fetchpatch {
      hash = "sha256-3o8d5h0eRkghav2vuG6eERf6u6GJSKEaqmnGhfBXbjk=";
      url = "https://github.com/stan-dev/cmdstanpy/commit/f08c69835d2d4a69c7e526d939757b8f609da8f6.patch";
    })
  ];

  postPatch = ''
    # conftest.py would have used git to clean up, which is unnecessary here
    rm test/conftest.py
  '';

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    pandas
    numpy
    tqdm
    stanio
  ];

  nativeCheckInputs = [ pytestCheckHook ] ++ finalAttrs.passthru.optional-dependencies.all;

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  disabledTestPaths = [
    # No need to test these when using Nix
    "test/test_install_cmdstan.py"
    "test/test_cxx_installation.py"
  ];

  disabledTests = [
    "test_serialization" # Pickle class mismatch errors
    # These tests use the flag -DSTAN_THREADS which doesn't work in cmdstan (missing file)
    "test_multi_proc_threads"
    "test_compile_force"
    # These tests require a writeable cmdstan source directory
    "test_pathfinder_threads"
    "test_save_profile"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "test_init_types" # CmdStan error: error during processing Operation not permitted
  ];

  optional-dependencies = {
    all = [ xarray ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cmdstanpy" ];
  pythonRelaxDeps = [ "stanio" ];

  meta = {
    description = "Lightweight interface to Stan for Python users";
    homepage = "https://github.com/stan-dev/cmdstanpy";
    changelog = "https://github.com/stan-dev/cmdstanpy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
