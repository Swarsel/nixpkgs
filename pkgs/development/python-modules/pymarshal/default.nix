{
  lib,
  fetchFromGitHub,
  bson,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymarshal";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "stargateaudio";
    repo = "pymarshal";
    rev = version;
    hash = "sha256-o+eWa3XFDFn+fyVxWOI9LbKqBUVsYR8O7J4sFbSGvEg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner'" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    bson
    pyyaml
  ];

  build-system = [ setuptools ];
  dependencies = [ bson ];
  enabledTestPaths = [ "test" ];
  pyproject = true;

  meta = {
    description = "Python data serialization library";
    homepage = "https://github.com/stargateaudio/pymarshal";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
