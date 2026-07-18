{
  lib,
  fetchFromGitHub,
  coq,
  python3,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "coq-jupyter";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "EugeneLoy";
    repo = "coq_jupyter";
    rev = "v${version}";
    sha256 = "sha256-+Pp51cxeqjg5MW4CEccNWVjNcY9iyFNATIEage9RWJ0=";
  };

  nativeBuildInputs = [ coq ];

  propagatedBuildInputs =
    (with python3.pkgs; [
      ipykernel
      future
    ])
    ++ [ coq ];

  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Jupyter kernel for Coq";
    homepage = "https://github.com/EugeneLoy/coq_jupyter";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thomasjm ];
  };
}
