{
  lib,
  stdenv,
  fetchFromGitHub,
  # dashboard
  buildNpmPackage,
  fetchNpmDeps,
  macmon,
  nix-update-script,
  python3Packages,
  replaceVars,
  # pyo3-bindings
  rustPlatform,
  writableTmpDirAsHomeHook,
}:
let
  version = "1.0.71";
  src = fetchFromGitHub {
    owner = "exo-explore";
    repo = "exo";
    tag = "v${version}";
    hash = "sha256-k3jtrJCxLx8nq1R70CtZWFyNVXEa5Ltw0MgdA0qFVXA=";
    name = "exo";
  };

  pyo3-bindings = python3Packages.buildPythonPackage (finalAttrs: {
    inherit version src;
    pname = "exo-pyo3-bindings";

    nativeBuildInputs = [
      rustPlatform.cargoSetupHook
      rustPlatform.maturinBuildHook
    ];

    # Bypass rust nightly features not being available on rust stable
    env.RUSTC_BOOTSTRAP = 1;
    # The only test is failing
    doCheck = false;
    buildAndTestSubdir = "rust/exo_pyo3_bindings";

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src version;
      hash = "sha256-gwOdA2sHz8n4GfNjK+OYmttXUTle4WYmAE2Y0KXYrwg=";
    };

    pyproject = true;
  });

  dashboard = buildNpmPackage (finalAttrs: {
    inherit src version;
    pname = "exo-dashboard";

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;

      fetcherVersion = 3;
      hash = "sha256-gBWJP0dF2zDEWLYxfKYQSn9O5hVRkcviDv9oP267pQQ=";
    };

    npmDepsFetcherVersion = 3;
    sourceRoot = "${finalAttrs.src.name}/dashboard";
  });
in
python3Packages.buildPythonApplication (finalAttrs: {
  inherit version src;
  pname = "exo";

  patches = [
    (replaceVars ./inject-dashboard-path.patch {
      dashboard = "${dashboard}/lib/node_modules/${dashboard.pname}/build";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.9,<0.9.0" "uv_build"
  ''
  # MemoryObjectStreamState was renamed in
  # https://github.com/agronholm/anyio/pull/1009/changes/bdc945a826d0d5917aea3517ceb9fe335b468094
  + ''
    substituteInPlace src/exo/utils/channels.py \
      --replace-fail \
        "MemoryObjectStreamState as AnyioState," \
        "_MemoryObjectStreamState as AnyioState,"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace src/exo/utils/info_gatherer/info_gatherer.py \
      --replace-fail \
        'shutil.which("macmon")' \
        '"${lib.getExe macmon}"'
  '';

  nativeCheckInputs = [
    python3Packages.pytest-asyncio
    python3Packages.pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  # Otherwise fails with 'import file mismatch'
  preCheck = ''
    rm src/exo/__init__.py
  '';

  # 'resources' are not getting copied to the installation directory, so we do it manually
  # FileNotFoundError: Unable to locate resources. Did you clone the repo properly?
  postInstall = ''
    cp -r resources $out/${python3Packages.python.sitePackages}/exo/
  '';

  build-system = with python3Packages; [
    uv-build
  ];

  dependencies =
    with python3Packages;
    [
      aiofiles
      aiohttp
      aiohttp-cors
      anyio
      fastapi
      filelock
      grpcio
      grpcio-tools
      httpx
      huggingface-hub
      hypercorn
      jinja2
      loguru
      mflux
      mlx
      mlx-lm
      mlx-vlm
      msgspec
      nvidia-ml-py
      openai
      openai-harmony
      opencv-python
      pillow
      prometheus-client
      psutil
      pydantic
      pyo3-bindings
      python-multipart
      rustworkx
      scapy
      tiktoken
      tinygrad
      tomlkit
      transformers
      uvloop
      zstandard
    ]
    ++ sqlalchemy.optional-dependencies.asyncio;

  disabledTestPaths = [
    # All tests hang indefinitely
    "src/exo/worker/tests/unittests/test_mlx/test_tokenizers.py"
  ];

  disabledTests = [
    # AttributeError: type object 'builtins.Keypair' has no attribute 'generate_ed25519'
    "test_sleep_on_multiple_items"

    # Require internet access:
    # openai_harmony.HarmonyError: error downloading or loading vocab file: failed to download or load vocab file
    "TestParseGptOssMaxTokensTruncation"
    "test_both_formats_produce_identical_tool_calls"
    "test_format_a_yields_tool_call"
    "test_format_b_yields_tool_call"
    "test_thinking_then_text_counts_reasoning_tokens"
    "test_thinking_then_tool_call"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # AssertionError: assert "MacMon not found in PATH" in str(exc_info.value)
    "test_macmon_not_found_raises_macmon_error"

    # ValueError: zip() argument 2 is longer than argument 1
    "test_events_processed_in_correct_order"

    # system_profiler is not available in the sandbox
    "test_tb_parsing"

    # Flaky in the sandbox (even when __darwinAllowLocalNetworking is enabled)
    # RuntimeError - Attempted to create a NULL object.
    "test_sleep_on_multiple_items"

    # Flaky in the sandbox (even when __darwinAllowLocalNetworking is enabled)
    # AssertionError: Expected 2 results, got 0. Errors: {0: "[ring] Couldn't bind socket (error: 1)"}
    "test_composed_call_works"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "exo"
    "exo.main"
  ];

  pythonRelaxDeps = true;

  pythonRemoveDeps = [
    "types-aiofiles"
    "uuid"
  ];

  passthru = {
    exo-dashboard = dashboard;
    exo-pyo3-bindings = pyo3-bindings;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Run your own AI cluster at home with everyday devices";
    homepage = "https://github.com/exo-explore/exo";
    changelog = "https://github.com/exo-explore/exo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "exo";
  };
})
