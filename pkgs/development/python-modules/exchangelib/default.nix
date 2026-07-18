{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cached-property,
  defusedxml,
  dnspython,
  isodate,
  lxml,
  oauthlib,
  psutil,
  pygments,
  python-dateutil,
  pytz,
  pyyaml,
  requests,
  requests-gssapi,
  requests-mock,
  requests-ntlm,
  requests-oauthlib,
  setuptools,
  tzdata,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "exchangelib";
  version = "5.6.0";

  src = fetchFromGitHub {
    owner = "ecederstrand";
    repo = "exchangelib";
    tag = "v${version}";
    hash = "sha256-tmJq0AZLuOic63ziIr173lbz6sDF/u75Y2ASYnHHDTM=";
  };

  nativeCheckInputs = [
    psutil
    python-dateutil
    pytz
    pyyaml
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    cached-property
    defusedxml
    dnspython
    isodate
    lxml
    oauthlib
    pygments
    requests
    requests-ntlm
    requests-oauthlib
    tzdata
    tzlocal
  ];

  optional-dependencies = {
    complete = [
      requests-gssapi
      # requests-negotiate-sspi
    ];

    kerberos = [ requests-gssapi ];
    # sspi = [
    #   requests-negotiate-sspi
    # ];
  };

  pyproject = true;
  pythonImportsCheck = [ "exchangelib" ];
  pythonRelaxDeps = [ "defusedxml" ];

  meta = {
    description = "Client for Microsoft Exchange Web Services (EWS)";
    homepage = "https://github.com/ecederstrand/exchangelib";
    changelog = "https://github.com/ecederstrand/exchangelib/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd2;
  };
}
