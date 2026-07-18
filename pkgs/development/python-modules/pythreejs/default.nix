{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipydatawidgets,
  ipywidgets,
  jupyterlab,
  numpy,
  setuptools,
  traitlets,
}:

buildPythonPackage rec {
  pname = "pythreejs";
  version = "2.4.2";

  # github sources need to invoke npm, but no package-lock.json present:
  # https://github.com/jupyter-widgets/pythreejs/issues/419
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pWi/3Ew3l8TCM5FYko7cfc9vpKJnsI487FEh4geLW9Y=";
  };

  # It seems pythonRelaxDeps doesn't work for these
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "jupyterlab~=" "jupyterlab>="

    # https://github.com/jupyter-widgets/pythreejs/pull/420
    substituteInPlace setupbase.py \
      --replace-fail "import pipes" "" \
      --replace-fail "pipes.quote" "shlex.quote"
  '';

  # There are no tests
  doCheck = false;

  build-system = [
    jupyterlab
    setuptools
  ];

  dependencies = [
    ipywidgets
    ipydatawidgets
    numpy
    traitlets
  ];

  pyproject = true;
  pythonImportsCheck = [ "pythreejs" ];
  # Don't run npm install, all files are already where they should be present.
  # If we would run npm install, npm would detect package-lock.json is an old format,
  # and try to fetch more metadata from the registry, which cannot work in the sandbox.
  setupPyBuildFlags = [ "--skip-npm" ];

  meta = {
    description = "Interactive 3D graphics for the Jupyter Notebook and JupyterLab, using Three.js and Jupyter Widgets";
    homepage = "https://github.com/jupyter-widgets/pythreejs";
    changelog = "https://github.com/jupyter-widgets/pythreejs/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
