# FIXME: make gdk-pixbuf dependency optional
{
  lib,
  stdenv,
  buildPythonPackage,
  cairo,
  cffi,
  fetchPypi,
  flit-core,
  gdk-pixbuf,
  glib,
  numpy,
  pikepdf,
  pytestCheckHook,
  replaceVars,
  xcffib,
  withXcffib ? false,
}:

buildPythonPackage rec {
  pname = "cairocffi";
  version = "1.7.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-LkjuhkiE7Eo6NL+oyauZmfaIKG63FKFaQ+ydBow2VXs=";
  };

  patches = [
    # OSError: dlopen() failed to load a library: gdk-pixbuf-2.0 / gdk-pixbuf-2.0-0
    (replaceVars ./dlopen-paths.patch {
      cairo = cairo.out;
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
      gdk_pixbuf = gdk-pixbuf.out;
      glib = glib.out;
    })
    ./fix_test_scaled_font.patch
  ];

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    cairo
    cffi
  ]
  ++ lib.optional withXcffib xcffib;

  nativeCheckInputs = [
    numpy
    pikepdf
    pytestCheckHook
  ];

  # Cairo tries to load system fonts by default.
  # It's surfaced as a Cairo "out of memory" error in tests.
  __impureHostDeps = [ "/System/Library/Fonts" ];
  pyproject = true;
  pythonImportsCheck = [ "cairocffi" ];

  meta = {
    description = "cffi-based cairo bindings for Python";
    homepage = "https://github.com/SimonSapin/cairocffi";
    changelog = "https://github.com/Kozea/cairocffi/blob/v${version}/NEWS.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
