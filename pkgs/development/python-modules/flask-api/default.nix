{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  # dependencies
  flask,
  # tests
  markdown,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-api";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "flask-api";
    repo = "flask-api";
    tag = "v${version}";
    hash = "sha256-nHgeI5FLKkDp4uWO+0eaT4YSOMkeQ0wE3ffyJF+WzTM=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-vaCZ4gVlfQXyeksA44ydkjz2FxODHt3gTTP+ukJwEGY=";
      # werkzeug 3.0 support
      url = "https://github.com/flask-api/flask-api/commit/9c998897f67d8aa959dc3005d7d22f36568b6938.patch";
    })
  ];

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ flask ];

  nativeCheckInputs = [
    markdown
    pytestCheckHook
  ];

  pyproject = true;

  meta = {
    description = "Browsable web APIs for Flask";
    homepage = "https://github.com/flask-api/flask-api";
    changelog = "https://github.com/flask-api/flask-api/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
