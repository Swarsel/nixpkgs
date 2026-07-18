{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "python-reprshed";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "mentalisttraceur";
    repo = "python-reprshed";
    rev = "v${version}";
    hash = "sha256-XfmiewI74eDLKTAU6Ed76QXfJYMRb+idRACl6CW07ME=";
  };

  format = "setuptools";
  pythonImportsCheck = [ "reprshed" ];

  meta = {
    description = "Toolshed for writing great __repr__ methods quickly and easily";
    homepage = "https://github.com/mentalisttraceur/python-reprshed";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ netali ];
  };
}
