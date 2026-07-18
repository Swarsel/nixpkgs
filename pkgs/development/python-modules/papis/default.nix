{
  lib,
  fetchFromGitHub,
  # dependencies
  arxiv,
  beautifulsoup4,
  bibtexparser,
  buildPythonPackage,
  # optional dependencies
  chardet,
  citeproc-py,
  click,
  colorama,
  # tests
  docutils,
  dominate,
  filetype,
  git,
  habanero,
  # build-system
  hatchling,
  isbnlib,
  jinja2,
  lxml,
  markdownify,
  platformdirs,
  prompt-toolkit,
  pygments,
  pyparsing,
  pytest-cov-stub,
  pytestCheckHook,
  python-doi,
  python-slugify,
  pyyaml,
  requests,
  sphinx,
  sphinx-click,
  stevedore,
  whoosh,
  writableTmpDirAsHomeHook,
  # switch for optional dependencies
  withOptDeps ? false,
}:

buildPythonPackage (finalAttrs: {
  pname = "papis";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "papis";
    repo = "papis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G+ryUMBUEbGxUG+u2YwZbT04IAzOmajtIPXP12MaXsY=";
  };

  nativeCheckInputs = [
    docutils
    git
    pytestCheckHook
    pytest-cov-stub
    sphinx
    sphinx-click
    writableTmpDirAsHomeHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    arxiv
    beautifulsoup4
    bibtexparser
    click
    colorama
    dominate
    filetype
    habanero
    isbnlib
    lxml
    platformdirs
    prompt-toolkit
    pygments
    pyparsing
    python-doi
    python-slugify
    pyyaml
    requests
    stevedore
  ]
  ++ lib.optionals withOptDeps finalAttrs.passthru.optional-dependencies.complete;

  disabledTestPaths = [
    # Require network access
    "tests/downloaders"
    "papis/downloaders/usenix.py"
  ];

  disabledTests = [
    # Require network access
    "test_add_folder_name_cli"
    "test_add_link_cli"
    "test_get_matching_importers_by_name"
    "test_matching_importers_by_uri"
    "test_yaml_unicode_dump"
    # FileNotFoundError: Command not found: 'init'
    "test_git_cli"
  ]
  ++ lib.optionals withOptDeps [
    # Require network access
    "test_csl_style_download"
  ];

  enabledTestPaths = [
    "papis"
    "tests"
  ];

  optional-dependencies = {
    complete = [
      chardet
      citeproc-py
      jinja2
      markdownify
      whoosh
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "papis" ];

  meta = {
    description = "Powerful command-line document and bibliography manager";
    homepage = "https://papis.readthedocs.io/";
    changelog = "https://github.com/papis/papis/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      nico202
      teto
    ];

    mainProgram = "papis";
  };
})
