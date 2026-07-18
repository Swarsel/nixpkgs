{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cachecontrol,
  feedparser,
  gitpython,
  jsonfeed,
  mkdocs,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  validator-collection,
}:

buildPythonPackage (finalAttrs: {
  pname = "mkdocs-rss-plugin";
  version = "1.17.9";

  src = fetchFromGitHub {
    owner = "Guts";
    repo = "mkdocs-rss-plugin";
    tag = finalAttrs.version;
    hash = "sha256-rUMjS0+895SsU7qNckLL3BprUQa/3lJDjpwhMkF0jYg=";
  };

  nativeCheckInputs = [
    feedparser
    jsonfeed
    pytest-cov-stub
    pytestCheckHook
    validator-collection
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cachecontrol
    gitpython
    mkdocs
  ]
  ++ cachecontrol.optional-dependencies.filecache;

  disabledTestPaths = [
    # Tests require network access
    "tests/test_integrations_material_social_cards.py"
    "tests/test_build_no_git.py"
    "tests/test_build.py"
  ];

  disabledTests = [
    # Tests require network access
    "test_plugin_config_through_mkdocs"
    "test_remote_image"
    # Configuration error
    "test_plugin_config_blog_enabled"
    "test_plugin_config_social_cards_enabled_but_integration_disabled"
    "test_plugin_config_theme_material"
    "test_simple_build"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_rss_plugin" ];

  meta = {
    description = "MkDocs plugin to generate a RSS feeds for created and updated pages, using git log and YAML frontmatter";
    homepage = "https://github.com/Guts/mkdocs-rss-plugin";
    changelog = "https://github.com/Guts/mkdocs-rss-plugin/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
