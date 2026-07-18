{
  lib,
  stdenv,
  buildPythonPackage,
  cssselect,
  fetchpatch,
  gobject-introspection,
  gtk3,
  inkscape,
  lxml,
  numpy,
  pillow,
  poetry-core,
  pygobject3,
  pyparsing,
  pyserial,
  pytestCheckHook,
  scour,
  tinycss2,
}:

buildPythonPackage {
  inherit (inkscape) version;
  inherit (inkscape) src;
  pname = "inkex";

  patches = [
    # Fix tests with newer libxml2
    # https://gitlab.com/inkscape/extensions/-/merge_requests/712
    (fetchpatch {
      extraPrefix = "share/extensions/";
      hash = "sha256-BXRcfoeX7X8+x6CuKKBhrnzUHIwgnPay22Z8+rPZS54=";
      stripLen = 1;
      url = "https://gitlab.com/inkscape/extensions/-/commit/b04ab718b400778a264f2085bbc779faebc08368.patch";
    })

    # Fix binary DXF parsing on big-endian
    # https://gitlab.com/inkscape/extensions/-/merge_requests/721
    ./1001-dxf-fix-binary-dxf-double-parsing-on-big-endian.patch
  ];

  postPatch = ''
    cd share/extensions

    substituteInPlace pyproject.toml \
      --replace-fail 'scour = "^0.37"' 'scour = ">=0.37"'
  '';

  nativeCheckInputs = [
    gobject-introspection
    pytestCheckHook
  ];

  checkInputs = [
    gtk3
  ];

  build-system = [ poetry-core ];

  dependencies = [
    cssselect
    lxml
    numpy
    pillow
    pygobject3
    pyparsing
    pyserial
    scour
    tinycss2
  ];

  disabledTestPaths = [
    # Fatal Python error: Segmentation fault
    "tests/test_inkex_gui.py"
    "tests/test_inkex_gui_listview.py"
    "tests/test_inkex_gui_window.py"
    # Failed to find pixmap 'image-missing' in /build/source/tests/data/
    "tests/test_inkex_gui_pixmaps.py"
  ];

  disabledTests = [
    "test_extract_multiple"
    "test_lookup_and"
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin [
    "test_image_extract"
    "test_path_number_nodes"
    "test_plotter" # Hangs
  ];

  pyproject = true;
  pythonImportsCheck = [ "inkex" ];

  pythonRelaxDeps = [
    "lxml"
    "numpy"
  ];

  meta = {
    description = "Library for manipulating SVG documents which is the basis for Inkscape extensions";
    homepage = "https://gitlab.com/inkscape/extensions";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
