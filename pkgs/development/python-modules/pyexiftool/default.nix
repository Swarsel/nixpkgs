{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  exiftool,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyexiftool";
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "sylikc";
    repo = "pyexiftool";
    tag = "v${version}";
    hash = "sha256-dgQkbpCbdq2JbupY0DyQbHPR9Bg+bwDo7yN03o3sX+A=";
  };

  postPatch = ''
    substituteInPlace exiftool/constants.py \
      --replace-fail 'DEFAULT_EXECUTABLE = "exiftool"' \
                     'DEFAULT_EXECUTABLE = "${lib.getExe exiftool}"'
  '';

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "exiftool" ];

  meta = {
    description = "Python wrapper for exiftool";
    homepage = "https://github.com/sylikc/pyexiftool";
    changelog = "https://github.com/sylikc/pyexiftool/blob/${src.rev}/CHANGELOG.md";

    license = with lib.licenses; [
      bsd3 # or
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
