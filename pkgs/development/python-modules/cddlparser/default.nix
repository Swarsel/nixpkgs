{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  setuptools,
}:

buildPythonPackage rec {
  pname = "cddlparser";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "tidoust";
    repo = "cddlparser";
    tag = "v${version}";
    sha256 = "sha256-LcIxU77bYpsuE4j1QgzdD3d7CO/EUEA9xwn+uIV68Oc=";
  };

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Concise data definition language (RFC 8610) parser implementation in Python";

    longDescription = ''
      A CDDL parser in Python

      Concise data definition language (RFC 8610) parser implementation in Python.
    '';

    homepage = "https://github.com/tidoust/cddlparser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hemera ];
    downloadPage = "https://github.com/tidoust/cddlparser/releases";
  };
}
