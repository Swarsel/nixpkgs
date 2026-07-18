{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # test dependencies
  mock,
  # optional dependencies
  pykerberos,
  pytestCheckHook,
  # build system
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pure-sasl";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "thobbs";
    repo = "pure-sasl";
    tag = version;
    hash = "sha256-AHoZ3QZLr0JLE8+a2zkB06v2wRknxhgm/tcEPXaJX/U=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
    six
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  optional-dependencies = {
    gssapi = [ pykerberos ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "puresasl"
    "puresasl.client"
    "puresasl.mechanisms"
  ];

  meta = {
    description = "Reasonably high-level SASL client written in pure Python";
    homepage = "http://github.com/thobbs/pure-sasl";
    changelog = "https://github.com/thobbs/pure-sasl/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jherland ];
  };
}
