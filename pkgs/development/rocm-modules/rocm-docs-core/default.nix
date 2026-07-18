{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  breathe,
  buildPythonPackage,
  fastjsonschema,
  gitUpdater,
  gitpython,
  myst-nb,
  myst-parser,
  pydata-sphinx-theme,
  pygithub,
  pyyaml,
  setuptools,
  sphinx,
  sphinx-book-theme,
  sphinx-copybutton,
  sphinx-design,
  sphinx-external-toc,
  sphinx-notfound-page,
}:

# FIXME: Move to rocmPackages_common
buildPythonPackage (finalAttrs: {
  pname = "rocm-docs-core";
  version = "1.34.0";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-docs-core";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dVX+e0nk9/GT0idXNvLwCuN8Fh/r0dWIvqToU9cxKxs=";
  };

  buildInputs = [ setuptools ];

  propagatedBuildInputs = [
    beautifulsoup4
    gitpython
    pydata-sphinx-theme
    pygithub
    sphinx
    breathe
    myst-nb
    myst-parser
    sphinx-book-theme
    sphinx-copybutton
    sphinx-design
    sphinx-external-toc
    sphinx-notfound-page
    pyyaml
    fastjsonschema
  ];

  pyproject = true;
  pythonImportsCheck = [ "rocm_docs" ];
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "ROCm Documentation Python package for ReadTheDocs build standardization";
    homepage = "https://github.com/ROCm/rocm-docs-core";

    license = with lib.licenses; [
      mit
      cc-by-40
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
