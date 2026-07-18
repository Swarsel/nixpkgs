{
  lib,
  stdenv,
  buildPythonPackage,
  cairosvg,
  fetchPypi,
  # dependencies
  importlib-metadata,
  # optional-dependencies
  lxml,
  # tests
  pyquery,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "pygal";
  version = "3.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+97nNRp0I+eQf7ipw7dzBfa1Z4yy5v0Ns2qIJeQpVew=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail pytest-runner ""
  '';

  nativeCheckInputs = [
    pyquery
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    # necessary on darwin to pass the testsuite
    export LANG=en_US.UTF-8
  '';

  postCheck = ''
    export LANG=${if stdenv.hostPlatform.isDarwin then "en_US.UTF-8" else "C.UTF-8"}
  '';

  # Cairo tries to load system fonts by default.
  # It's surfaced as a Cairo "out of memory" error in tests.
  __impureHostDeps = [ "/System/Library/Fonts" ];
  build-system = [ setuptools ];
  dependencies = [ importlib-metadata ];

  optional-dependencies = {
    lxml = [ lxml ];
    png = [ cairosvg ];
  };

  pyproject = true;

  meta = {
    description = "Module for dynamic SVG charting";
    homepage = "http://www.pygal.org";
    changelog = "https://github.com/Kozea/pygal/blob/${version}/docs/changelog.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    mainProgram = "pygal_gen.py";
    downloadPage = "https://github.com/Kozea/pygal";
  };
}
