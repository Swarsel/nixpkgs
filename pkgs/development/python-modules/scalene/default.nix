{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cloudpickle,
  cython,
  hypothesis,
  jinja2,
  numpy,
  nvidia-ml-py,
  psutil,
  pydantic,
  pytestCheckHook,
  python,
  pyyaml,
  rich,
  setuptools,
  setuptools-scm,
}:

let
  heap-layers-src = fetchFromGitHub {
    hash = "sha256-p+8aUC124Digv3c9fZ7lLHg6H8FXoAcAQxlYzf9TYbM=";
    name = "Heap-Layers";
    owner = "emeryberger";
    repo = "heap-layers";
    tag = "v1.0.0";
  };

  printf-src = fetchFromGitHub {
    hash = "sha256-tgLJNJw/dJGQMwCmfkWNBvHB76xZVyyfVVplq7aSJnI=";
    name = "printf";
    owner = "mpaland";
    repo = "printf";
    tag = "v4.0.0";
  };

  pythonPath = lib.getExe python;
in

buildPythonPackage (finalAttrs: {
  pname = "scalene";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "plasma-umass";
    repo = "scalene";
    tag = "v${finalAttrs.version}";
    hash = "sha256-a8laU7w6DLNIxmfhis/PvYd0iQMSqiQ2j6WURbsWPxk=";
  };

  patches = [
    ./01-manifest-no-git.patch
  ];

  postPatch = ''
    # Fix hash mismatch
    rm vendor/printf/printf.c

    # Set correct sys.executable
    substituteInPlace tests/test_{multiprocessing_pool_spawn,on_off_windows}.py \
      --replace-fail "sys.executable" "\"${pythonPath}\""
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    hypothesis
    numpy
  ];

  # remove scalene directory to prevent pytest import confusion
  preCheck = ''
    rm -rf scalene
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    cython
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cloudpickle
    jinja2
    numpy
    psutil
    pydantic
    pyyaml
    rich
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ nvidia-ml-py ];

  disabledTestPaths = [
    # Broken pipe
    # https://github.com/plasma-umass/scalene/issues/1017
    "tests/test_coverup_50.py"
    "tests/test_multiprocessing_spawn.py::TestReplacementSemLockPickling"
    "tests/test_multiprocessing_spawn.py::TestSpawnModeIntegration"
  ];

  disabledTests = [
    # Flaky -- socket collision
    "test_show_browser"
    # File not found
    "test_nested_package_relative_import"
  ];

  prePatch = ''
    mkdir vendor
    cp -r ${heap-layers-src} vendor/Heap-Layers
    mkdir vendor/printf
    cp ${printf-src}/printf.c vendor/printf/printf.cpp
    cp -r ${printf-src}/* vendor/printf
    sed -i 's/^#define printf printf_/\/\/&/' vendor/printf/printf.h
    sed -i 's/^#define vsnprintf vsnprintf_/\/\/&/' vendor/printf/printf.h
  '';

  pyproject = true;
  pythonImportsCheck = [ "scalene" ];

  pythonRemoveDeps = [
    "nvidia-ml-py3"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "nvidia-ml-py" ];

  meta = {
    description = "High-resolution, low-overhead CPU, GPU, and memory profiler for Python with AI-powered optimization suggestions";
    homepage = "https://github.com/plasma-umass/scalene";
    changelog = "https://github.com/plasma-umass/scalene/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sarahec ];

    badPlatforms = [
      # The scalene doesn't seem to account for arm64 linux
      "aarch64-linux"

      # On darwin, builds mistakenly compile one part as x86 and the
      # other as arm64 then tries to link them into a single binary
      # which fails.
      "aarch64-darwin"
    ];

    mainProgram = "scalene";
  };
})
