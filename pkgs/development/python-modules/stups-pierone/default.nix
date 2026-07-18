{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytestCheckHook,
  requests,
  setuptools,
  stups-cli-support,
  stups-zign,
}:

buildPythonPackage rec {
  pname = "stups-pierone";
  version = "1.1.51";

  src = fetchFromGitHub {
    owner = "zalando-stups";
    repo = "pierone-cli";
    rev = version;
    hash = "sha256-OypGYHfiFUfcUndylM2N2WfPnfXXJ4gvWypUbltYAYE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  preCheck = ''
    export HOME=$TEMPDIR
  '';

  build-system = [ setuptools ];

  dependencies = [
    requests
    stups-cli-support
    stups-zign
  ];

  pyproject = true;
  pythonImportsCheck = [ "pierone" ];
  pythonRelaxDeps = [ "stups-zign" ];

  meta = {
    description = "Convenient command line client for STUPS' Pier One Docker registry";
    homepage = "https://github.com/zalando-stups/pierone-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mschuwalow ];
  };
}
