{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
}:

buildPythonPackage rec {
  pname = "mpldatacursor";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "joferkington";
    repo = "mpldatacursor";
    rev = "v${version}";
    sha256 = "0i1lwl6x6hgjq4xwsc138i4v5895lmnpfqwpzpnj5mlck6fy6rda";
  };

  propagatedBuildInputs = [ matplotlib ];
  # No tests included in archive
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "mpldatacursor" ];

  meta = {
    description = "Interactive data cursors for matplotlib";
    homepage = "https://github.com/joferkington/mpldatacursor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bzizou ];
  };
}
