{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication {
  pname = "hekatomb";
  version = "1.5.14-unstable-2024-02-14";

  src = fetchFromGitHub {
    owner = "ProcessusT";
    repo = "HEKATOMB";
    rev = "8cd372fd5d93e8b43c2cbe2ab2cada635f00e9dd";
    hash = "sha256-2juP2SuCfY4z2J27BlodrsP+29BjGxKDIDOW0mmwCPY=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    chardet
    dnspython
    impacket
    ldap3
    pycryptodomex
  ];

  # Project has no tests
  doCheck = false;
  pyproject = true;

  pythonImportsCheck = [
    "hekatomb"
  ];

  pythonRelaxDeps = [
    "impacket"
  ];

  meta = {
    description = "Tool to connect to LDAP directory to retrieve informations";
    homepage = "https://github.com/ProcessusT/HEKATOMB";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "hekatomb";
  };
}
