{
  lib,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  # buildInputs
  buildbox,
  fuse3,
  gitMinimal,
  gitUpdater,
  # nativeBuildInputs
  installShellFiles,
  lzip,
  patch,
  python3Packages,
  versionCheckHook,
  # Optional features
  enableBuildstreamPlugins ? true,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "buildstream";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "buildstream";
    tag = finalAttrs.version;
    hash = "sha256-eHZmimuwOo3ZHZw5QF94B6wkso1+QbZIcgpDgsw1hiM=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    fuse3
    lzip
    patch
  ];

  nativeCheckInputs = [
    addBinToPathHook
    buildbox
    gitMinimal
    python3Packages.pexpect
    python3Packages.pyftpdlib
    python3Packages.pytest-datafiles
    python3Packages.pytest-env
    python3Packages.pytest-timeout
    python3Packages.pytest-xdist
    python3Packages.pytestCheckHook
    versionCheckHook
  ];

  postInstall = ''
    installShellCompletion --cmd bst \
      --bash src/buildstream/data/bst \
      --zsh src/buildstream/data/zsh/_bst
  '';

  build-system = with python3Packages; [
    cython
    pdm-pep517
    setuptools
    setuptools-scm
  ];

  dependencies = [
    buildbox
  ]
  ++ (with python3Packages; [
    click
    grpcio
    jinja2
    markupsafe
    packaging
    pluginbase
    protobuf
    psutil
    pyroaring
    ruamel-yaml
    ruamel-yaml-clib
    ujson
  ])
  ++ lib.optionals enableBuildstreamPlugins [
    python3Packages.buildstream-plugins
  ];

  disabledTestPaths = [
    # FileNotFoundError: [Errno 2] No such file or directory: '/build/source/tmp/popen-gw1/test_report_when_cascache_exit0/buildbox-casd'
    "tests/internals/cascache.py"
  ];

  disabledTests = [
    # Error loading project: project.conf [line 37 column 2]: Failed to load source-mirror plugin 'mirror': No package metadata was found for sample-plugins
    "test_source_mirror_plugin"

    # AssertionError: assert '1a5528cad211...0bbe5ee314c14' == '2ccfee62a657...52dbc47203a88'
    "test_fixed_cas_import"
    "test_random_cas_import"

    # Runtime error: The FUSE stager child process unexpectedly died with exit code 2
    "test_patch_sources_cached_1"
    "test_patch_sources_cached_2"
    "test_source_cache_key"
    "test_custom_transform_source"

    # Blob not found in the local CAS
    "test_source_pull_partial_fallback_fetch"
  ];

  pyproject = true;
  pythonImportsCheck = [ "buildstream" ];
  versionCheckProgram = "${placeholder "out"}/bin/bst";

  passthru.updateScript = gitUpdater {
    ignoredVersions = "dev";
  };

  meta = {
    description = "Powerful software integration tool";
    homepage = "https://buildstream.build";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ shymega ];
    platforms = lib.platforms.linux;
    mainProgram = "bst";
    downloadPage = "https://buildstream.build/install.html";
  };
})
