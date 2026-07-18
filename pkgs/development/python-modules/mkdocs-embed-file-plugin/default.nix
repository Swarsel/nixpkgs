{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  hatchling,
  markdown,
  mdx-wikilink-plus,
  mkdocs,
  mkdocs-callouts,
  mkdocs-custom-tags-attributes,
  pymdown-extensions,
  python-frontmatter,
  ruamel-yaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mkdocs-embed-file-plugin";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "ObsidianPublisher";
    repo = "mkdocs-embed_file-plugin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6FmMMaR+gyp5Gx0oXiDYvsr6uA8hwrV93YYrYkJsMNY=";
  };

  # No tests available.
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    beautifulsoup4
    markdown
    mdx-wikilink-plus
    mkdocs
    mkdocs-callouts
    mkdocs-custom-tags-attributes
    pymdown-extensions
    python-frontmatter
    ruamel-yaml
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_embed_file_plugins"
  ];

  meta = {
    description = "A way to embed a file present in your docs";
    homepage = "https://github.com/ObsidianPublisher/mkdocs-embed_file-plugin";
    changelog = "https://github.com/ObsidianPublisher/mkdocs-embed_file-plugin/blob/${finalAttrs.src.rev}/CHANGELOG.md";

    license = with lib.licenses; [
      agpl3Only
      agpl3Plus
    ];

    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "mkdocs-embed-file-plugin";
  };
})
