{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  flask,
  pytestCheckHook,
  setuptools,
  webassets,
}:

buildPythonPackage rec {
  pname = "flask-assets";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "miracle2k";
    repo = "flask-assets";
    tag = version;
    hash = "sha256-R6cFTT+r/i5j5/QQ+cCFmeuO7SNTiV1F+e0JTxwIUGY=";
  };

  patches = [
    # On master branch but not in a release.
    (fetchpatch2 {
      hash = "sha256-Feo7gHHmHtWRB+3XvlECdU4i5rpyjyKEYEUCuy24rf4=";
      name = "refactor-with-pytest.patch";
      url = "https://github.com/miracle2k/flask-assets/commit/56e06dbb160c165e0289ac97496354786fe3f3fd.patch?full_index=1";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    flask
    webassets
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_assets" ];

  meta = {
    description = "Asset management for Flask, to compress and merge CSS and Javascript files";
    homepage = "https://github.com/miracle2k/flask-assets";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
