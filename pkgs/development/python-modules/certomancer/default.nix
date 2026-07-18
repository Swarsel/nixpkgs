{
  lib,
  fetchFromGitHub,
  # dependencies
  asn1crypto,
  buildPythonPackage,
  click,
  cryptography,
  # nativeCheckInputs
  freezegun,
  jinja2,
  pyhanko-certvalidator,
  pytest-aiohttp,
  pytestCheckHook,
  python-dateutil,
  python-pkcs11,
  pytz,
  pyyaml,
  requests,
  # optional-dependencies
  requests-mock,
  # build-system
  setuptools,
  setuptools-scm,
  tzlocal,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "certomancer";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "MatthiasValvekens";
    repo = "certomancer";
    tag = "v${version}";
    hash = "sha256-rsugn1g8iYESrC+IUSbxCAbwnKXWG+ubbUj9QdZB+Ow=";
  };

  nativeCheckInputs = [
    freezegun
    pyhanko-certvalidator
    pytest-aiohttp
    pytestCheckHook
    pytz
    requests
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asn1crypto
    click
    cryptography
    python-dateutil
    pyyaml
    tzlocal
  ];

  optional-dependencies = {
    pkcs11 = [ python-pkcs11 ];
    requests-mocker = [ requests-mock ];

    web-api = [
      jinja2
      werkzeug
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "certomancer" ];

  meta = {
    description = "Quickly construct, mock & deploy PKI test configurations using simple declarative configuration";
    homepage = "https://github.com/MatthiasValvekens/certomancer";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "certomancer";
  };
}
