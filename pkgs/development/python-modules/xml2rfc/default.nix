{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  configargparse,
  decorator,
  dict2xml,
  google-i18n-address,
  intervaltree,
  jinja2,
  lxml,
  platformdirs,
  pycairo,
  pycountry,
  pypdf,
  pytestCheckHook,
  python-fontconfig,
  pyyaml,
  requests,
  setuptools,
  wcwidth,
}:

buildPythonPackage rec {
  pname = "xml2rfc";
  version = "3.33.0";

  src = fetchFromGitHub {
    owner = "ietf-tools";
    repo = "xml2rfc";
    tag = "v${version}";
    hash = "sha256-eoTuA4OJjqJGRP+uRi2TMWfS3yrCCUPIKI2uNPnjqcA=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "SHELL := /bin/bash" "SHELL := bash" \
      --replace-fail "test flaketest" "test"
  '';

  # Requires Noto Serif and Roboto Mono font
  doCheck = false;

  nativeCheckInputs = [
    decorator
    pycairo
    pytestCheckHook
    python-fontconfig
  ];

  checkPhase = ''
    make tests-no-network
  '';

  build-system = [ setuptools ];

  dependencies = [
    configargparse
    dict2xml
    google-i18n-address
    intervaltree
    jinja2
    lxml
    platformdirs
    pycountry
    pypdf
    pyyaml
    requests
    wcwidth
  ];

  pyproject = true;
  pythonImportsCheck = [ "xml2rfc" ];
  pythonRelaxDeps = [ "lxml" ];

  meta = {
    description = "Tool generating IETF RFCs and drafts from XML sources";
    homepage = "https://github.com/ietf-tools/xml2rfc";
    changelog = "https://github.com/ietf-tools/xml2rfc/blob/${src.tag}/CHANGELOG.md";
    # Well, parts might be considered unfree, if being strict; see:
    # http://metadata.ftp-master.debian.org/changelogs/non-free/x/xml2rfc/xml2rfc_2.9.6-1_copyright
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      vcunat
      yrashk
    ];

    mainProgram = "xml2rfc";
  };
}
