{
  lib,
  stdenv,
  fetchFromGitHub,
  annexremote,
  # misc
  argcomplete,
  # downloaders
  boto3,
  buildPythonPackage,
  chardet,
  # win
  colorama,
  curl,
  distro,
  # duecredit
  duecredit,
  fasteners,
  git,
  git-annex,
  httpretty,
  humanize,
  installShellFiles,
  iso8601,
  keyring,
  keyrings-alt,
  looseversion,
  msgpack,
  p7zip,
  packaging,
  patool,
  # core
  platformdirs,
  pyperclip,
  # tests
  pytest-retry,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  # publish
  python-gitlab,
  pythonAtLeast,
  requests,
  setuptools,
  tqdm,
  versioneer,
}:

buildPythonPackage (finalAttrs: {
  pname = "datalad";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "datalad";
    repo = "datalad";
    tag = finalAttrs.version;
    hash = "sha256-5PAHHN+dgMAxqUZn3vXWsoesw3lQMy6Q8nUJYa4SofM=";
  };

  postPatch = ''
    # Remove vendorized versioneer.py
    rm versioneer.py
  '';

  nativeBuildInputs = [
    installShellFiles
    git
  ];

  nativeCheckInputs = [
    p7zip
    pytest-retry
    pytest-xdist
    pytestCheckHook
    git-annex
    curl
    httpretty
  ];

  preCheck = ''
    export HOME=$TMPDIR
    export DATALAD_TESTS_NONETWORK=1
    export PATH="$PATH:$out/bin"
  '';

  postInstall = ''
    installShellCompletion --cmd datalad \
      --bash <($out/bin/datalad shell-completion) \
      --zsh  <($out/bin/datalad shell-completion)
    wrapProgram $out/bin/datalad \
      --prefix PATH : "${git-annex}/bin" \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  # Tests use ports on localhost
  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    versioneer
  ];

  dependencies =
    finalAttrs.passthru.optional-dependencies.core
    ++ finalAttrs.passthru.optional-dependencies.downloaders
    ++ finalAttrs.passthru.optional-dependencies.publish;

  disabledTestMarks = [
    "flaky"
  ];

  disabledTests = [
    # Tries to run `git` and fails
    "test_reckless"
    "test_create"
    "test_subsuperdataset_save"

    # Tries to spawn a subshell and fails
    "test_shell_completion_source"

    # Times out
    "test_rerun_unrelated_nonrun_left_run_right"

    # Top five slowest (2/3 of total runtime)
    "test_files_split"
    "test_gitannex_local"
    "test_save_hierarchy"
    "test_recurse_existing"
    "test_source_candidate_subdataset"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # pbcopy not found
    "test_wtf"
    # hangs
    "test_keyring"
  ];

  optional-dependencies = {
    core = [
      platformdirs
      chardet
      distro
      iso8601
      humanize
      fasteners
      packaging
      patool
      tqdm
      annexremote
      looseversion
    ]
    ++ lib.optionals stdenv.hostPlatform.isWindows [ colorama ];

    downloaders = [
      boto3
      keyrings-alt
      keyring
      msgpack
      requests
    ];

    downloaders-extra = [
      # requests-ftp # not in nixpkgs yet
    ];

    duecredit = [ duecredit ];

    misc = [
      argcomplete
      pyperclip
      python-dateutil
    ];

    publish = [ python-gitlab ];
  };

  pyproject = true;

  pytestFlags = [
    # Deprecated in 3.13. Use exc_type_str instead.
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "datalad" ];

  meta = {
    description = "Keep code, data, containers under control with git and git-annex";
    homepage = "https://www.datalad.org";
    changelog = "https://github.com/datalad/datalad/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      renesat
      malik
      sarahec
    ];
  };
})
