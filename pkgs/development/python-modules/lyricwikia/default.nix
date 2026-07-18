{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  responses,
  six,
}:

buildPythonPackage rec {
  pname = "lyricwikia";
  version = "0.1.11";

  src = fetchFromGitHub {
    owner = "enricobacis";
    repo = "lyricwikia";
    tag = version;
    hash = "sha256-P88DrRAa2zptt8JLy0/PLi0oZ/BghF/XGSP0kOObi7E=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "'pytest-runner'" ""
  '';

  propagatedBuildInputs = [
    beautifulsoup4
    requests
    six
  ];

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  disabledTests = [
    # Test requires network access
    "test_integration"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "lyricwikia" ];

  meta = {
    description = "LyricWikia API for song lyrics";
    homepage = "https://github.com/enricobacis/lyricwikia";
    changelog = "https://github.com/enricobacis/lyricwikia/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kmein ];
    mainProgram = "lyrics";
  };
}
