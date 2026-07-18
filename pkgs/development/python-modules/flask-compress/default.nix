{
  lib,
  fetchFromGitHub,
  backports-zstd,
  brotli,
  brotlicffi,
  buildPythonPackage,
  flask,
  flask-caching,
  isPyPy,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  zstandard,
}:

buildPythonPackage rec {
  pname = "flask-compress";
  version = "1.24";

  src = fetchFromGitHub {
    owner = "colour-science";
    repo = "flask-compress";
    tag = "v${version}";
    hash = "sha256-JbPBu8FWp/HnYbA2vTKiy2gopS5U0JNDV7ucTAYrLVY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools_scm[toml]<8" "setuptools_scm"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    flask-caching
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    backports-zstd
    flask
  ]
  ++ lib.optionals (!isPyPy) [ brotli ]
  ++ lib.optionals isPyPy [ brotlicffi ];

  pyproject = true;
  pythonImportsCheck = [ "flask_compress" ];

  meta = {
    description = "Compress responses in your Flask app with gzip, deflate or brotli";
    homepage = "https://github.com/colour-science/flask-compress";
    changelog = "https://github.com/colour-science/flask-compress/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
