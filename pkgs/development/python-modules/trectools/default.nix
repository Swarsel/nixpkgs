{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  lxml,
  matplotlib,
  numpy,
  pandas,
  python,
  sarge,
  scikit-learn,
  scipy,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage {
  pname = "trectools";
  version = "0.0.50";

  src = fetchFromGitHub {
    owner = "joaopalotti";
    repo = "trectools";
    # https://github.com/joaopalotti/trectools/issues/41
    rev = "8a896def007e3d657eb29f820ee3de98e2f32691";
    hash = "sha256-p8BvLO+rD/l+ATE4+u3I6k25R1RVKlk2dn+RLQZTLDs=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "bs4 >= 0.0.0.1" "beautifulsoup4 >= 4.11.1"
  '';

  nativeCheckInputs = [
    unittestCheckHook
  ];

  preCheck = ''
    # tests pass numpy arrays to float(), which numpy 2 rejects
    rm unittests/testtreceval.py
  '';

  build-system = [ setuptools ];

  dependencies = [
    pandas
    numpy
    scikit-learn
    scipy
    lxml
    beautifulsoup4
    matplotlib
    sarge
  ];

  format = "setuptools";
  pythonImportsCheck = [ "trectools" ];

  unittestFlagsArray = [
    "unittests/"
  ];

  meta = {
    description = "Library for assisting Information Retrieval (IR) practitioners with TREC-like campaigns";
    homepage = "https://github.com/joaopalotti/trectools";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ MoritzBoehme ];
  };
}
