{
  lib,
  stdenv,
  cmake,
  fetchPypi,
  fetchpatch,
  flex,
  glib,
  gst_all_1,
  json-glib,
  libxml2,
  llvmPackages,
  pkg-config,
  python3Packages,
  replaceVars,
}:

python3Packages.buildPythonApplication rec {
  pname = "hotdoc";
  version = "0.17.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xNXf9kfwOqh6HS0GA10oGe3QmbkWNeOy7jkIKTV66fw=";
  };

  patches = [
    (replaceVars ./clang.patch {
      clang = lib.getExe llvmPackages.clang;
      libclang_lib_dir = "${lib.getLib llvmPackages.libclang}/lib";
    })

    # Fix build with gcc15
    (fetchpatch {
      hash = "sha256-5y50Yk+AjV3aSk8H3k9od/Yvy09FyQQOcVOAcstQnw8=";
      name = "hotdoc-fix-c_comment_scanner-function-prototypes-gcc15.patch";
      url = "https://github.com/hotdoc/hotdoc/commit/adf8518431fafb78c9b47862a0a9a58824b6a421.patch";
    })
  ];

  postPatch = ''
    patch -p1 -d cmark -i ${./fix-cmake-4.patch}
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
    flex
  ];

  buildInputs = [
    glib
    json-glib
    libxml2
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  # Make pytest run from a temp dir to have it pick up installed package for cmark
  preCheck = ''
    pushd $TMPDIR
  '';

  postCheck = ''
    popd
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    appdirs
    backports-entry-points-selectable
    dbus-deviation
    faust-cchardet
    feedgen
    lxml
    networkx
    pkgconfig
    pyyaml
    schema
    setuptools # for pkg_resources
    toposort
    wheezy-template
  ];

  disabledTests = [
    # Test does not correctly handle path normalization for test comparison
    "test_cli_overrides"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Test does not correctly handle absolute /home paths on Darwin (even fake ones)
    "test_index"
  ];

  # CMake is used to build CMARK, but the build system is still python
  dontUseCmakeConfigure = true;
  pyproject = true;

  pytestFlags = [
    # Run the tests by package instead of current dir
    "--pyargs"
    "hotdoc"
  ];

  # Ensure C+GI+GST extensions are built and can be imported
  pythonImportsCheck = [
    "hotdoc.extensions.c.c_extension"
    "hotdoc.extensions.gi.gi_extension"
    "hotdoc.extensions.gst.gst_extension"
  ];

  passthru.tests = {
    inherit (gst_all_1) gstreamer gst-plugins-base;
  };

  meta = {
    description = "Tastiest API documentation system";
    homepage = "https://hotdoc.github.io/";
    license = [ lib.licenses.lgpl21Plus ];
    maintainers = [ ];
  };
}
