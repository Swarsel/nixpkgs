{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "jamo";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "JDongian";
    repo = "python-jamo";
    tag = "v${version}";
    hash = "sha256-QHI3Rqf1aQOsW49A/qnIwRnPuerbtyerf+eWIiEvyho=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "jamo" ];

  meta = {
    description = "Hangul syllable decomposition and synthesis using jamo";
    homepage = "https://github.com/JDongian/python-jamo";
    changelog = "https://github.com/JDongian/python-jamo/releases/tag/v${version}";
    license = lib.licenses.asl20;
    teams = [ lib.teams.tts ];
  };
}
