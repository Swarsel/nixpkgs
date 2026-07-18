{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  click,
  gtts-token,
  mock,
  pytest,
  requests,
  setuptools,
  six,
  testfixtures,
  twine,
  urllib3,
}:

buildPythonPackage rec {
  pname = "gtts";
  version = "2.5.4";

  src = fetchFromGitHub {
    owner = "pndurette";
    repo = "gTTS";
    tag = "v${version}";
    hash = "sha256-ryTR7cESDO9pH5r2FBz+6JuNMEQr39hil/FSklgaIGg=";
  };

  # majority of tests just try to call out to Google's Translate API endpoint
  doCheck = false;

  nativeCheckInputs = [
    pytest
    mock
    testfixtures
  ];

  checkPhase = ''
    pytest
  '';

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    click
    gtts-token
    requests
    six
    urllib3
    twine
  ];

  pyproject = true;
  pythonImportsCheck = [ "gtts" ];

  pythonRelaxDeps = [
    "click"
  ];

  meta = {
    description = "Python library and CLI tool to interface with Google Translate text-to-speech API";
    homepage = "https://gtts.readthedocs.io";
    changelog = "https://gtts.readthedocs.io/en/latest/changelog.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ unode ];
    mainProgram = "gtts-cli";
  };
}
