{
  lib,
  fetchPypi,
  python3,
}:

let
  py = python3.override {
    packageOverrides = self: super: {
      wtforms = super.wtforms.overridePythonAttrs (oldAttrs: rec {
        version = "2.3.1";

        src = fetchPypi {
          inherit version;
          sha256 = "sha256-hhoTs65SHWcA2sOydxlwvTVKY7pwQ+zDqCtSiFlqGXI=";
          pname = "WTForms";
        };

        doCheck = false;
      });
    };

    self = py;
  };
in
py.pkgs.buildPythonApplication rec {
  pname = "archivy";
  version = "1.7.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XFzWD4KAW5jt5BwXZvO0iZdJKpzC6dRkxNLv5N8XUfc=";
  };

  # __init__.py attempts to mkdir in read-only file system
  doCheck = false;

  build-system = with py.pkgs; [
    setuptools
  ];

  dependencies = with py.pkgs; [
    appdirs
    attrs
    beautifulsoup4
    click-plugins
    elasticsearch
    flask-compress
    flask-login
    flask-wtf
    html2text
    python-dotenv
    python-frontmatter
    readability-lxml
    requests
    setuptools # uses pkg_resources during runtime
    tinydb
    validators
    wtforms
  ];

  pyproject = true;
  pythonRelaxDeps = true;

  meta = {
    description = "Self-hosted knowledge repository";
    homepage = "https://archivy.github.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}
