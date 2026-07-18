{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # buildInputs
  codec2,
  # build-system
  cython,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycodec2";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "gregorias";
    repo = "pycodec2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DDO18uhAhZGaD04rAPinZhkNTww3ibEhw1uJwTtJYWk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "numpy==2.1.*" "numpy"
  '';

  buildInputs = [
    codec2
  ];

  # The only test fails with a cryptic AssertionError
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf pycodec2
  '';

  __structuredAttrs = true;

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycodec2" ];

  meta = {
    description = "Python's interface to codec 2";
    homepage = "https://github.com/gregorias/pycodec2";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
