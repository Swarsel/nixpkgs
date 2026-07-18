{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
}:

buildPythonPackage rec {
  pname = "mergedeep";
  version = "1.3.4";

  # PyPI tarball doesn't include tests directory
  src = fetchFromGitHub {
    owner = "clarketm";
    repo = "mergedeep";
    rev = "v${version}";
    sha256 = "1msvvdzk33sxzgyvs4fs8dlsrsi7fjj038z83s0yw5h8m8d78469";
  };

  nativeCheckInputs = [ pytest ];
  checkPhase = "pytest";
  format = "setuptools";
  pythonImportsCheck = [ "mergedeep" ];

  meta = {
    description = "Deep merge function for python";
    homepage = "https://github.com/clarketm/mergedeep";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ris ];
  };
}
