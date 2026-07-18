{
  lib,
  fetchFromGitHub,
  babel,
  backrefs,
  buildPythonPackage,
  cairosvg,
  colorama,
  hatch-nodejs-version,
  hatch-requirements-txt,
  hatchling,
  jinja2,
  markdown,
  mkdocs,
  mkdocs-git-revision-date-localized-plugin,
  mkdocs-material-extensions,
  mkdocs-minify-plugin,
  mkdocs-redirects,
  mkdocs-rss-plugin,
  paginate,
  pillow,
  pygments,
  pymdown-extensions,
  regex,
  requests,
  trove-classifiers,
}:

buildPythonPackage (finalAttrs: {
  pname = "mkdocs-material";
  version = "9.7.6";

  src = fetchFromGitHub {
    owner = "squidfunk";
    repo = "mkdocs-material";
    tag = finalAttrs.version;
    hash = "sha256-qQtVnWNSh7rJhVyufkebEq6n4lpBI3tZxHRT07AIZFA=";
  };

  # No tests for python
  doCheck = false;

  build-system = [
    hatch-requirements-txt
    hatch-nodejs-version
    hatchling
    trove-classifiers
  ];

  dependencies = [
    babel
    backrefs
    colorama
    jinja2
    markdown
    mkdocs
    mkdocs-material-extensions
    paginate
    pygments
    pymdown-extensions
    regex
    requests
  ];

  optional-dependencies = {
    git = [
      # TODO: gmkdocs-git-committers-plugin
      mkdocs-git-revision-date-localized-plugin
    ];

    imaging = [
      cairosvg
      pillow
    ];

    recommended = [
      mkdocs-minify-plugin
      mkdocs-redirects
      mkdocs-rss-plugin
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mkdocs" ];
  pythonRelaxDeps = [ "backrefs" ];

  meta = {
    description = "Material for mkdocs";
    homepage = "https://squidfunk.github.io/mkdocs-material/";
    changelog = "https://github.com/squidfunk/mkdocs-material/blob/${finalAttrs.src.tag}/CHANGELOG";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dandellion
      jaysa68
    ];

    downloadPage = "https://github.com/squidfunk/mkdocs-material";
  };
})
