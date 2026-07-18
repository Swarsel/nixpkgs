{
  lib,
  fetchFromGitLab,
  makeWrapper,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "asn2quickder";
  version = "1.7.1";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "quick-der";
    rev = "v${version}";
    hash = "sha256-f+ph5PL+uWRkswpOLDwZFWjh938wxoJ6xocJZ2WZLEk=";
  };

  postPatch = ''
    patchShebangs ./python/scripts/*

    # Unpin pyparsing 3.0.0. Issue resolved in latest version.
    substituteInPlace setup.py --replace 'pyparsing==3.0.0' 'pyparsing'
  '';

  nativeBuildInputs = [
    makeWrapper
    python3Packages.cmake
  ];

  propagatedBuildInputs = with python3Packages; [
    pyparsing
    asn1ate
    six
    colored
  ];

  doCheck = false; # Flaky tests
  dontUseCmakeConfigure = true;
  format = "setuptools";

  meta = {
    description = "ASN.1 compiler with a backend for Quick DER";
    homepage = "https://gitlab.com/arpa2/quick-der";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
}
