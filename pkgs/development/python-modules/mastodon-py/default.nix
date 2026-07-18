{
  lib,
  fetchFromGitHub,
  blurhash,
  buildPythonPackage,
  cryptography,
  decorator,
  graphemeu,
  http-ece,
  pytest-cov-stub,
  pytest-mock,
  pytest-vcr,
  pytestCheckHook,
  python-dateutil,
  python-magic,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mastodon-py";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "halcy";
    repo = "Mastodon.py";
    tag = "v${version}";
    hash = "sha256-RsSM7TkNwsirT1ksaXP/IKOmrpPrNGh/16S77Up+3MM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    pytest-vcr
    requests-mock
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    blurhash
    decorator
    python-dateutil
    python-magic
    requests
  ];

  optional-dependencies = {
    blurhash = [ blurhash ];
    grapheme = [ graphemeu ];

    webpush = [
      http-ece
      cryptography
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mastodon" ];

  meta = {
    description = "Python wrapper for the Mastodon API";
    homepage = "https://github.com/halcy/Mastodon.py";
    changelog = "https://github.com/halcy/Mastodon.py/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
