{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  mock,
  # dependencies
  pillow,
  # build-system
  poetry-core,
  pypng,
  pytestCheckHook,
  pythonAtLeast,
  qrcode,
  testers,
}:

buildPythonPackage rec {
  pname = "qrcode";
  version = "8.2";

  src = fetchFromGitHub {
    owner = "lincolnloop";
    repo = "python-qrcode";
    tag = "v${version}";
    hash = "sha256-qLIYUFnBJQGidnfC0bQAkO/aUmT94uXFMeMhnUgUnfQ=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ poetry-core ];

  disabledTests = lib.optionals (pythonAtLeast "3.12") [ "test_change" ] ++ [
    # Attempts to open a file which doesn't exist in sandbox
    "test_piped"
  ];

  optional-dependencies = {
    all = [
      pypng
      pillow
    ];

    pil = [ pillow ];
    png = [ pypng ];
  };

  pyproject = true;

  passthru.tests = {
    version = testers.testVersion {
      command = "qr --version";
      package = qrcode;
    };
  };

  meta = {
    description = "Python QR Code image generator";
    homepage = "https://github.com/lincolnloop/python-qrcode";
    changelog = "https://github.com/lincolnloop/python-qrcode/blob/v${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ attila ];
    mainProgram = "qr";
  };
}
