{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  fontconfig,
  # plotting
  gdal,
  # nativeBuildInputs
  geos,
  # dependencies
  matplotlib,
  numpy,
  # optional-dependencies
  # ows
  owslib,
  pillow,
  proj,
  pyproj,
  pyshp,
  pytest-mpl,
  pytestCheckHook,
  scipy,
  setuptools-scm,
  shapely,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "cartopy";
  version = "0.25.0.post2";

  src = fetchFromGitHub {
    owner = "SciTools";
    repo = "cartopy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N5cE+VKux5Wu2CtGujuMy3UA1fZBFkD+Fin/rb4rtUM=";
  };

  nativeBuildInputs = [
    geos # for geos-config
    proj
  ];

  buildInputs = [
    geos
    proj
  ];

  nativeCheckInputs = [
    pytest-mpl
    pytestCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    export FONTCONFIG_FILE=${fontconfig.out}/etc/fonts/fonts.conf
  '';

  __structuredAttrs = true;

  build-system = [
    cython
    setuptools-scm
  ];

  dependencies = [
    matplotlib
    numpy
    pyproj
    pyshp
    shapely
  ];

  disabledTestMarks = [
    "network"
    "natural_earth"
  ];

  disabledTests = [
    # Numerical errors. Example:
    #   AssertionError: Arrays are not almost equal to 4 decimals
    "test_LatitudeFormatter_mercator"
    "test_cursor_values"
    "test_default"
    "test_extents"
    "test_geoaxes_no_subslice"
    "test_geoaxes_set_boundary_clipping"
    "test_get_extent"
    "test_gridliner_labels_zoom"
    "test_infinite_loop_bounds"
    "test_invalid_xy_domain_corner"
    "test_invalid_y_domain"
    "test_osgb_vals"
    "test_pcolormesh_datalim"
    "test_plot_after_contour_doesnt_shrink"
    "test_sweep"
    "test_tiny_point_between_boundary_points"
    "test_transform_point"
    "test_with_transform"

    # Failed: Error: Image files did not match.
    "test_background_img"
    "test_gridliner_constrained_adjust_datalim"
    "test_imshow"
    "test_pil_Image"
    "test_stock_img"
  ];

  optional-dependencies = {
    ows = [
      owslib
      pillow
    ];

    plotting = [
      gdal
      pillow
      scipy
    ];
  };

  pyproject = true;

  pytestFlags = [
    "--pyargs"
    "cartopy"
  ];

  meta = {
    description = "Process geospatial data to create maps and perform analyses";
    homepage = "https://scitools.org.uk/cartopy/docs/latest/";
    changelog = "https://github.com/SciTools/cartopy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    mainProgram = "feature_download";
    teams = [ lib.teams.geospatial ];
  };
})
