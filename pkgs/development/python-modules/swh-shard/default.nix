{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  click,
  cmake,
  cmph,
  ninja,
  pkg-config,
  pybind11,
  pytest-mock,
  pytestCheckHook,
  scikit-build-core,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-shard";
  version = "2.2.1";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-shard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-acspStM+ohWDSqLH/aapWkI/VqAXnJCqeLTJ+lBlDcE=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cmph
  ];

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    # import from $out
    rm src/swh/shard/*.py
  '';

  build-system = [
    cmake
    ninja
    pybind11
    scikit-build-core
    setuptools-scm
  ];

  dependencies = [
    click
  ];

  disabledTests = [
    "test_setup_log_handler_with_env_configuration"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # assert (51675136 - 51396608) < (100 * 1024)
    "test_memleak"
    # ValueError: Cannot convert negative int
    "test_write_above_rlimit_fsize"
    # ValueError: Cannot convert negative int
    "test_finalize_above_rlimit_fsize"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "swh.shard" ];

  meta = {
    description = "Shard File Format for the Software Heritage Object Storage";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-shard";
    changelog = "https://gitlab.softwareheritage.org/swh/devel/swh-shard/-/tags/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      dotlambda
      drupol
    ];
  };
})
