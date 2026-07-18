{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  isPy3k,
  numpy,
  pytest,
  toml,
}:

buildPythonPackage rec {
  pname = "finalfusion";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-python";
    rev = version;
    sha256 = "0pwzflamxqvpl1wcz0zbhhd6aa4xn18rmza6rggaic3ckidhyrh4";
  };

  postPatch = ''
    patchShebangs tests/integration

    # `np.float` was a deprecated alias of the builtin `float`
    substituteInPlace tests/test_storage.py \
      --replace 'dtype=np.float)' 'dtype=float)'
  '';

  nativeBuildInputs = [ cython ];

  propagatedBuildInputs = [
    numpy
    toml
  ];

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    # Regular unit tests.
    pytest

    # Integration tests for command-line utilities.
    PATH=$PATH:$out/bin tests/integration/all.sh
  '';

  disabled = !isPy3k;
  format = "setuptools";

  meta = {
    description = "Python module for using finalfusion, word2vec, and fastText word embeddings";
    homepage = "https://github.com/finalfusion/finalfusion-python/";
    license = lib.licenses.blueOak100;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
