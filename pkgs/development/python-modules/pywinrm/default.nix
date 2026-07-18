{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  pykerberos,
  pytestCheckHook,
  requests,
  requests-credssp,
  requests-ntlm,
  setuptools,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pywinrm";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VCjrHklK95VFRs1P8Vye8aMKdeBbJaOf1gbO8iIB6fE=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    requests
    requests-ntlm
    xmltodict
  ];

  enabledTestPaths = [ "winrm/tests/" ];

  optional-dependencies = {
    credssp = [ requests-credssp ];
    kerberos = [ pykerberos ];
  };

  pyproject = true;
  pythonImportsCheck = [ "winrm" ];

  meta = {
    description = "Python library for Windows Remote Management";
    homepage = "https://github.com/diyan/pywinrm";
    changelog = "https://github.com/diyan/pywinrm/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kamadorueda
    ];
  };
}
