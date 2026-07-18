{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "sipvicious";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "EnableSecurity";
    repo = "sipvicious";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qUdK8IbLnuQU3hv6+x3R84y83Ts8lNIGsOANFgkReE0=";
  };

  # Project has no tests
  doCheck = false;

  postInstall = ''
    installManPage man1/*.1
  '';

  build-system = [
    installShellFiles
  ]
  ++ (with python3.pkgs; [
    setuptools
  ]);

  dependencies = with python3.pkgs; [
    scapy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sipvicious"
  ];

  meta = {
    description = "Set of tools to audit SIP based VoIP systems";
    homepage = "https://github.com/EnableSecurity/sipvicious";
    changelog = "https://github.com/EnableSecurity/sipvicious/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
