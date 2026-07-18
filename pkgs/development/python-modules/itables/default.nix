{
  lib,
  anywidget,
  buildPythonPackage,
  # build-system
  dash,
  fetchPypi,
  hatch-jupyter-builder,
  hatchling,
  # optional-dependencies
  ipython,
  marimo,
  matplotlib,
  narwhals,
  # nativeBuildInputs
  nodejs,
  numpy,
  pandas,
  polars,
  pyarrow,
  python,
  pyyaml,
  setuptools,
  streamlit,
  traitlets,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "itables";
  version = "2.8.1";

  # itables has 4 different node packages, each with their own
  # package-lock.json, and partially depending on each other.
  # Our fetchNpmDeps tooling in nixpkgs doesn't support this yet, so we fetch
  # the source tarball from pypi, which includes the javascript bundle already.
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Vix9cW1mfz+vh//hBEoZdHo7Ix7mqncl62+QjKoYxCk=";
  };

  nativeBuildInputs = [
    nodejs
  ];

  # don't run the hooks, as they try to invoke npm on packages/,
  env.HATCH_BUILD_NO_HOOKS = true;
  # no tests in pypi tarball
  doCheck = false;

  # The pyproject.toml shipped with the sources doesn't install anything,
  # as the paths in the pypi tarball are not the same as in the repo checkout.
  # We exclude itables_for_dash here, as it's missing the .dist-info dir
  # plumbing to be discoverable, and should be its own package anyways.
  postInstall = ''
    cp -R itables $out/${python.sitePackages}
  '';

  build-system = [
    dash
    hatchling
    hatch-jupyter-builder
    pyyaml
    setuptools
  ];

  # shiny and modin omitted due to missing deps
  optional-dependencies = {
    all = [
      pandas
      polars
      narwhals
      matplotlib
      ipython
      anywidget
      traitlets
      dash
      streamlit
      marimo
      pyarrow
    ];

    dash = [
      dash
      typing-extensions
    ];

    marimo = [ marimo ];
    narwhals = [ narwhals ];
    notebook = [ ipython ];

    other_dataframes = [
      narwhals
      pyarrow
    ];

    pandas = [ pandas ];
    polars = [ polars ];
    streamlit = [ streamlit ];

    style = [
      pandas
      matplotlib
    ];

    widget = [
      anywidget
      traitlets
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "itables" ];

  meta = {
    description = "Pandas and Polar DataFrames as interactive DataTables";
    homepage = "https://github.com/mwouts/itables";
    changelog = "https://github.com/mwouts/itables/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
