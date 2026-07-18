{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "dnstwist";
  version = "20250130";

  src = fetchFromGitHub {
    owner = "elceef";
    repo = "dnstwist";
    tag = finalAttrs.version;
    hash = "sha256-cgSQ6KDCvTYX0vp0jqNzKHzo84IXrztoYqoTJNF+FiI=";
  };

  # Project has no tests
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    dnspython
    geoip
    ppdeep
    requests
    tld
    whois
  ];

  pyproject = true;

  pythonImportsCheck = [
    "dnstwist"
  ];

  meta = {
    description = "Domain name permutation engine for detecting homograph phishing attacks";
    homepage = "https://github.com/elceef/dnstwist";
    changelog = "https://github.com/elceef/dnstwist/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "dnstwist";
  };
})
