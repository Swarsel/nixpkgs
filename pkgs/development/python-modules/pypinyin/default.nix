{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pypinyin";
  version = "0.55.0";

  src = fetchFromGitHub {
    owner = "mozillazg";
    repo = "python-pinyin";
    tag = "v${version}";
    hash = "sha256-Xd5dxEiaByjtZmlORyK4cBPfNyIcZwbF40SvEKZ24Ks=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  enabledTestPaths = [ "tests" ];
  format = "setuptools";

  meta = {
    description = "Chinese Characters to Pinyin - 汉字转拼音";
    homepage = "https://github.com/mozillazg/python-pinyin";
    changelog = "https://github.com/mozillazg/python-pinyin/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    mainProgram = "pypinyin";
    teams = [ lib.teams.tts ];
  };
}
