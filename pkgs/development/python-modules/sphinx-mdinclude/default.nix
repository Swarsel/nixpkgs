{
  lib,
  buildPythonPackage,
  # dependencies
  docutils,
  fetchPypi,
  # build-system
  flit-core,
  mistune,
  pygments,
  # tests
  pytestCheckHook,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinx-mdinclude";
  version = "0.6.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-RHRi6Cy4vmFASiIEIn+SB2nrkj0vV2COMyXzu4goa0w=";
    pname = "sphinx_mdinclude";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    docutils
    mistune
    pygments
    sphinx
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Sphinx extension for including or writing pages in Markdown format";

    longDescription = ''
      A simple Sphinx extension that enables including Markdown documents from within
      reStructuredText.
      It provides the .. mdinclude:: directive, and automatically converts the content of
      Markdown documents to reStructuredText format.

      sphinx-mdinclude is a fork of m2r and m2r2, focused only on providing a Sphinx extension.
    '';

    homepage = "https://github.com/omnilib/sphinx-mdinclude";
    changelog = "https://github.com/omnilib/sphinx-mdinclude/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      flokli
      JulianFP
    ];
  };
}
