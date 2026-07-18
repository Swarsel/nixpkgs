{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optionals
  genshi,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  webtest,
}:

buildPythonPackage rec {
  pname = "static3";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "rmohr";
    repo = "static3";
    rev = "v${version}";
    hash = "sha256-uFgv+57/UZs4KoOdkFxbvTEDQrJbb0iYJ5JoWWN4yFY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    webtest
  ]
  ++ lib.concatAttrValues optional-dependencies;

  format = "setuptools";

  optional-dependencies = {
    Genshimagic = [ genshi ];

    KidMagic = [
      # TODO: kid
    ];
  };

  pythonImportsCheck = [ "static" ];

  meta = {
    description = "Really simple WSGI way to serve static (or mixed) content";
    homepage = "https://github.com/rmohr/static3";
    changelog = "https://github.com/rmohr/static3/releases/tag/v${version}";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "static";
  };
}
