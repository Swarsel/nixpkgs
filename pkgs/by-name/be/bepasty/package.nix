{
  lib,
  fetchPypi,
  python3,
}:

let
  # bepasty 1.2 needs xstatic-font-awesome < 5, see
  # https://github.com/bepasty/bepasty-server/issues/305
  bepastyPython = python3.override {
    packageOverrides = self: super: {
      xstatic-bootstrap = super.xstatic-bootstrap.overridePythonAttrs (oldAttrs: rec {
        version = "4.5.3.1";

        src = oldAttrs.src.override {
          inherit version;
          hash = "sha256-z2fSBUN7MlCKiLaafnxbviylqK5xCXORpqb1EOv9KCA=";
          pname = "XStatic-Bootstrap";
        };
      });

      xstatic-font-awesome = super.xstatic-font-awesome.overridePythonAttrs (oldAttrs: rec {
        version = "4.7.0.0";

        src = oldAttrs.src.override {
          inherit version;
          hash = "sha256-4B+0gMqqfHlj3LMyikcA5jG+9gcNsOi2hYFtIg5oX2w=";
        };
      });
    };

    self = bepastyPython;
  };
in

# We need to use buildPythonPackage here to get the PYTHONPATH build correctly.
# This is needed for services.bepasty
# https://github.com/NixOS/nixpkgs/pull/38300

bepastyPython.pkgs.buildPythonPackage rec {
  pname = "bepasty";
  version = "1.2.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-teazPj+IrgbVeUkWqgWhpIldgfCTbZYJAqn5Q5blcm8=";
  };

  buildInputs = with bepastyPython.pkgs; [ setuptools-scm ];

  propagatedBuildInputs = with bepastyPython.pkgs; [
    flask
    markupsafe
    pygments
    setuptools
    xstatic
    xstatic-asciinema-player
    xstatic-bootbox
    xstatic-bootstrap
    xstatic-font-awesome
    xstatic-jquery
    xstatic-jquery-file-upload
    xstatic-jquery-ui
    xstatic-pygments
  ];

  nativeCheckInputs = with bepastyPython.pkgs; [
    build
    flake8
    pytestCheckHook
    pytest-cov-stub
    selenium
    tox
    twine
  ];

  disabledTestPaths = [
    # Can be enabled when werkzeug is updated to >2.2, see #245145
    # and https://github.com/bepasty/bepasty-server/pull/303
    "src/bepasty/tests/test_rest_server.py"

    # These require a web browser
    "src/bepasty/tests/screenshots.py"
    "src/bepasty/tests/test_website.py"
  ];

  pyproject = true;

  meta = {
    description = "Binary pastebin server";
    homepage = "https://github.com/bepasty/bepasty-server";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      aither64
      makefu
    ];
  };
}
