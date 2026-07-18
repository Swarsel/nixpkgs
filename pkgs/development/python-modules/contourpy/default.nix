{
  lib,
  fetchFromGitHub,
  # optionals
  bokeh,
  buildPythonPackage,
  chromedriver,
  # tests
  matplotlib,
  # build
  meson,
  meson-python,
  ninja,
  nukeReferences,
  # propagates
  numpy,
  pillow,
  pkg-config,
  pybind11,
  pytest-xdist,
  pytestCheckHook,
  python,
  selenium,
  wurlitzer,
}:

let
  contourpy = buildPythonPackage rec {
    pname = "contourpy";
    version = "1.3.3";

    src = fetchFromGitHub {
      owner = "contourpy";
      repo = "contourpy";
      tag = "v${version}";
      hash = "sha256-/tE+F1wH7YkqfgenXwtcfkjxUR5FwfgoS4NYC6n+/2M=";
    };

    # prevent unnecessary references to the build python when cross compiling
    postPatch = ''
      substituteInPlace lib/contourpy/util/_build_config.py.in \
        --replace-fail '@python_path@' "${python.interpreter}"
    '';

    nativeBuildInputs = [
      meson
      ninja
      nukeReferences
      pkg-config
    ];

    buildInputs = [
      pybind11
    ];

    doCheck = false; # infinite recursion with matplotlib, tests in passthru

    nativeCheckInputs = [
      matplotlib
      pillow
      pytestCheckHook
      pytest-xdist
      wurlitzer
    ];

    # remove references to buildPackages.python3, which is not allowed for cross builds.
    preFixup = ''
      nuke-refs $out/${python.sitePackages}/contourpy/util/{_build_config.py,__pycache__/_build_config.*}
    '';

    build-system = [ meson-python ];
    dependencies = [ numpy ];
    pyproject = true;
    pythonImportsCheck = [ "contourpy" ];

    passthru.optional-depdendencies = {
      bokeh = [
        bokeh
        chromedriver
        selenium
      ];
    };

    passthru.tests = {
      check = contourpy.overridePythonAttrs (_: {
        doCheck = true;
      });
    };

    meta = {
      description = "Python library for calculating contours in 2D quadrilateral grids";
      homepage = "https://github.com/contourpy/contourpy";
      changelog = "https://github.com/contourpy/contourpy/releases/tag/${src.tag}";
      license = lib.licenses.bsd3;
      maintainers = [ ];
    };
  };
in
contourpy
