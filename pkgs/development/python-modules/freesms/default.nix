{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httmock,
  poetry-core,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "freesms";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "bfontaine";
    repo = "freesms";
    tag = "v${version}";
    hash = "sha256-5f5amXH6VVppX9/9DhILdBU8w/6n67EUgBy/zgTEUCM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    httmock
  ];

  build-system = [ poetry-core ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "freesms" ];

  meta = {
    description = "Python interface for Free Mobile SMS API";
    homepage = "https://github.com/bfontaine/freesms";
    changelog = "https://github.com/bfontaine/freesms/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
