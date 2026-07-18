{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  fetchpatch,
  hypothesis,
  numpy,
  pyparsing,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "snuggs";
  version = "1.4.7";

  # Pypi doesn't ship the tests, so we fetch directly from GitHub
  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "snuggs";
    rev = version;
    sha256 = "1p3lh9s2ylsnrzbs931y2vn7mp2y2xskgqmh767c9l1a33shfgwf";
  };

  patches = [
    # Use non-strict xfail for failing tests
    # https://github.com/mapbox/snuggs/pull/28
    (fetchpatch {
      hash = "sha256-SfW4l4BH94rPdskRVHEsZM0twmlV9IPftRU/BBZsjBU=";
      url = "https://github.com/sebastic/snuggs/commit/3b8e04a35ed33a7dd89f0194542b22c7bde867f4.patch";
    })
  ];

  propagatedBuildInputs = [
    click
    numpy
    pyparsing
  ];

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  format = "setuptools";

  meta = {
    description = "S-expressions for Numpy";
    homepage = "https://github.com/mapbox/snuggs";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
