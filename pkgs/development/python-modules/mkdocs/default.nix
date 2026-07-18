{
  # eval time deps
  lib,
  fetchFromGitHub,
  # optional-dependencies
  babel,
  buildPythonPackage,
  # runtime deps
  click,
  ghp-import,
  # buildtime
  hatchling,
  jinja2,
  markdown,
  markupsafe,
  mergedeep,
  mkdocs-get-deps,
  # testing deps
  mock,
  packaging,
  pathspec,
  platformdirs,
  pythonAtLeast,
  pyyaml,
  pyyaml-env-tag,
  setuptools,
  unittestCheckHook,
  watchdog,
}:

buildPythonPackage rec {
  pname = "mkdocs";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "mkdocs";
    repo = "mkdocs";
    tag = version;
    hash = "sha256-JQSOgV12iYE6FubxdoJpWy9EHKFxyKoxrm/7arCn9Ak=";
  };

  patches = [
    # https://github.com/mkdocs/mkdocs/pull/4065
    ./click-8.3.0-compat.patch
  ];

  nativeCheckInputs = [
    unittestCheckHook
    mock
  ]
  ++ optional-dependencies.i18n;

  build-system = [
    hatchling
    # babel, setuptools required as "build hooks"
    babel
  ]
  ++ lib.optionals (pythonAtLeast "3.12") [ setuptools ];

  dependencies = [
    click
    ghp-import
    jinja2
    markdown
    markupsafe
    mergedeep
    mkdocs-get-deps
    packaging
    pathspec
    platformdirs
    pyyaml
    pyyaml-env-tag
    watchdog
  ];

  optional-dependencies = {
    i18n = [ babel ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mkdocs" ];

  unittestFlagsArray = [
    "-v"
    "-p"
    "'*tests.py'"
    "mkdocs"
  ];

  meta = {
    description = "Project documentation with Markdown / static website generator";

    longDescription = ''
      MkDocs is a fast, simple and downright gorgeous static site generator that's
      geared towards building project documentation. Documentation source files
      are written in Markdown, and configured with a single YAML configuration file.

      MkDocs can also be used to generate general-purpose websites.
    '';

    homepage = "http://mkdocs.org/";
    changelog = "https://github.com/mkdocs/mkdocs/releases/tag/${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ rkoe ];
    platforms = lib.platforms.unix;
    mainProgram = "mkdocs";
    downloadPage = "https://github.com/mkdocs/mkdocs";
  };
}
