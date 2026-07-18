{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  # optional-dependencies
  # bts
  debianbts,
  # tests
  docutils,
  dogpile-cache,
  # gmail
  google-api-python-client,
  google-auth-oauthlib,
  jinja2,
  # jira
  jira,
  # keyring
  keyring,
  lockfile,
  # trac
  offtrac,
  pydantic,
  pytestCheckHook,
  # bugzilla
  python-bugzilla,
  python-dateutil,
  requests,
  responses,
  # build-system
  setuptools,
  sphinx,
  sphinx-click,
  sphinx-inline-tabs,
  taskw,
  taskwarrior3,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "bugwarrior";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "GothenburgBitFactory";
    repo = "bugwarrior";
    tag = finalAttrs.version;
    hash = "sha256-Px0yOIdXalIJdXMmjMnpl74aaUzaptS8Esy21NMZH98=";
  };

  nativeCheckInputs = [
    docutils
    pytestCheckHook
    responses
    sphinx
    sphinx-click
    sphinx-inline-tabs
    taskwarrior3
    versionCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    click
    dogpile-cache
    jinja2
    lockfile
    pydantic
    python-dateutil
    requests
    taskw
  ]
  ++ pydantic.optional-dependencies.email;

  disabledTestPaths = [
    # Optional dependencies for these services aren't packaged.
    "tests/test_kanboard.py"
    "tests/test_phab.py"
    "tests/test_todoist.py"
  ];

  disabledTests = [
    # Requires ini2toml dependency, which isn't packaged.
    "TestIni2Toml"
    # Import services for which the optional dependencies aren't packaged.
    "TestValidation"
    "ExampleTest"
    "TestServices"

    # Remove test that depend on ruff to prevent it from having too many consumers
    "test_ruff_check"
    "test_ruff_format"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # sphinx.errors.ExtensionError: Could not import extension config
    # (exception: No module named 'ini2toml')
    "test_docs_build_without_warning"
    "test_manpage_build_without_warning"
  ];

  optional-dependencies = {
    bts = [ debianbts ];
    bugzilla = [ python-bugzilla ];

    gmail = [
      google-api-python-client
      google-auth-oauthlib
    ];

    jira = [ jira ];
    keyring = [ keyring ];
    trac = [ offtrac ];
  };

  pyproject = true;
  pythonImportsCheck = [ "bugwarrior" ];

  meta = {
    description = "Sync github, bitbucket, bugzilla, and trac issues with taskwarrior";
    homepage = "https://github.com/GothenburgBitFactory/bugwarrior";
    changelog = "https://github.com/GothenburgBitFactory/bugwarrior/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      pierron
      ryneeverett
    ];

    platforms = lib.platforms.all;
    mainProgram = "bugwarrior";
  };
})
