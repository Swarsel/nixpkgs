{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  diskcache,
  numpy,
  packaging,
  pytestCheckHook,
  requests,
  scikit-image,
  six,
  tifffile,
}:

buildPythonPackage rec {
  pname = "slicedimage";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "spacetx";
    repo = "slicedimage";
    rev = version;
    sha256 = "1vpg8varvfx0nj6xscdfm7m118hzsfz7qfzn28r9rsfvrhr0dlcw";
  };

  propagatedBuildInputs = [
    boto3
    diskcache
    packaging
    numpy
    requests
    scikit-image
    six
    tifffile
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  # Ignore tests which require setup, check again if disabledTestFiles can be used
  disabledTestPaths = [ "tests/io_" ];
  format = "setuptools";
  pythonImportsCheck = [ "slicedimage" ];

  meta = {
    description = "Library to access sliced imaging data";
    homepage = "https://github.com/spacetx/slicedimage";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "slicedimage";
  };
}
