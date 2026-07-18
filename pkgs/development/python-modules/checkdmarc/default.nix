{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  dnspython,
  expiringdict,
  hatchling,
  importlib-resources,
  pem,
  publicsuffixlist,
  pyleri,
  pyopenssl,
  pytestCheckHook,
  requests,
  timeout-decorator,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "checkdmarc";
  version = "5.17.3";

  src = fetchFromGitHub {
    owner = "domainaware";
    repo = "checkdmarc";
    tag = finalAttrs.version;
    hash = "sha256-OI96936+4Jcx3VuPmHI2tcIssPxC7ofmLwWcvZxMw7E=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    cryptography
    dnspython
    expiringdict
    importlib-resources
    pem
    publicsuffixlist
    pyleri
    pyopenssl
    requests
    timeout-decorator
    xmltodict
  ];

  disabledTests = [
    # Tests require network access
    "testBIMI"
    "testDMARCPctLessThan100Warning"
    "testSPFMissingARecord"
    "testSPFMissingMXRecord"
    "testSplitSPFRecord"
    "testTooManySPFDNSLookups"
    "testTooManySPFVoidDNSLookups"
    "testDNSSEC"
    "testDnssecFalseWhenNoKey"
    "testGetDnskeyCache"
    "testIncludeMissingSPF"
    "testKnownGood"
  ];

  pyproject = true;
  pythonImportsCheck = [ "checkdmarc" ];

  pythonRelaxDeps = [
    "cryptography"
    "xmltodict"
  ];

  meta = {
    description = "Parser for SPF and DMARC DNS records";
    homepage = "https://github.com/domainaware/checkdmarc";
    changelog = "https://github.com/domainaware/checkdmarc/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "checkdmarc";
  };
})
