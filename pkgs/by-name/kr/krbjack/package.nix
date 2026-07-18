{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "krbjack";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "almandin";
    repo = "krbjack";
    tag = finalAttrs.version;
    hash = "sha256-rvK0I8WlXqJtau9f+6ximfzYCjX21dPIyDN56IMI0gE=";
  };

  # Project has no tests
  doCheck = false;

  build-system = with python3.pkgs; [
    poetry-core
  ];

  dependencies = with python3.pkgs; [
    colorama
    dnspython
    impacket
    scapy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "krbjack"
  ];

  pythonRelaxDeps = [
    "impacket"
  ];

  meta = {
    description = "Kerberos AP-REQ hijacking tool with DNS unsecure updates abuse";
    homepage = "https://github.com/almandin/krbjack";
    changelog = "https://github.com/almandin/krbjack/releases/tag/${finalAttrs.version}";
    license = lib.licenses.beerware;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "krbjack";
  };
})
