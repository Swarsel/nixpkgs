{
  lib,
  buildPythonPackage,
  # Dependencies
  click,
  defusedxml,
  docutils,
  fetchPypi,
  # Checks
  pytestCheckHook,
  # Build system
  setuptools,
  setuptools-scm,
  sphinx,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "sphinx-click";
  version = "6.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-/Hi0FUpOUVlGLjbeVbhkN0fabNqGs7Uqi7YiieYDd2w=";
    pname = "sphinx_click";
  };

  postPatch = ''
    # Would require reno which would require the .git directory to stay around
    substituteInPlace docs/changelog.rst \
      --replace-fail '.. release-notes::' 'Check https://sphinx-click.readthedocs.io/en/latest/changelog/ for the Release Notes.'
    substituteInPlace docs/conf.py \
      --replace-fail "'reno.sphinxext'" ""
  '';

  nativeBuildInputs = [
    sphinxHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    defusedxml
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    docutils
    sphinx
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sphinx_click"
  ];

  meta = {
    description = "Sphinx extension that automatically documents click applications";
    homepage = "https://github.com/click-contrib/sphinx-click";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ antonmosich ];
  };
}
