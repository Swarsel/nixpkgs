{
  lib,
  fetchurl,
  fetchFromGitHub,
  anywidget,
  buildPythonPackage,
  graphviz,
  h5py,
  ipympl,
  ipywidgets,
  # dependencies
  lazy-loader,
  matplotlib,
  mpltoolbox,
  pandas,
  plotly,
  pooch,
  pyarrow,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  pythreejs,
  scipp,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
  # tests data
  symlinkJoin,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "plopp";
  version = "26.7.0";

  src = fetchFromGitHub {
    owner = "scipp";
    repo = "plopp";
    tag = finalAttrs.version;
    hash = "sha256-TpoTOzdD8N9IcATmMRTfbSSBWwosxCW+MBa5MDtabf8=";
  };

  env = {
    # See: https://github.com/scipp/plopp/blob/25.05.0/src/plopp/data/examples.py
    PLOPP_DATA_DIR =
      let
        # NOTE this might be changed by upstream in the future.
        _version = "1";
      in
      symlinkJoin {
        name = "plopp-test-data";

        paths =
          lib.mapAttrsToList
            (
              file: hash:
              fetchurl {
                inherit hash;
                downloadToTemp = true;

                postFetch = ''
                  mkdir -p $out/${_version}
                  mv $downloadedFile $out/${_version}/${file}
                '';

                recursiveHash = true;
                url = "https://public.esss.dk/groups/scipp/plopp/${_version}/${file}";
              }
            )
            {
              "nyc_taxi_data.h5" = "sha256-hso8ESM+uLRf4y2CW/7dpAmm/kysAfJY3b+5vz78w4Q=";
              "teapot.h5" = "sha256-i6hOw72ce1cBT6FMQTdCEKVe0WOMOjApKperGHoPW34=";
            };
      };
  };

  nativeCheckInputs = [
    pytestCheckHook
    anywidget
    graphviz
    h5py
    ipympl
    ipywidgets
    mpltoolbox
    pandas
    plotly
    pooch
    pyarrow
    pythreejs
    scipp
    scipy
    xarray
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    lazy-loader
    matplotlib
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # https://github.com/scipp/plopp/issues/508
    "test_move_cut"
    "test_value_cuts"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "plopp"
  ];

  meta = {
    description = "Visualization library for scipp";
    homepage = "https://scipp.github.io/plopp/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
