{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  hypothesis,
  pyprojectVersionPatchHook,
  pytestCheckHook,
  python-dateutil,
  pythonOlder,
  replaceVars,
  typing-extensions,
  tzdata,
}:

buildPythonPackage rec {
  pname = "icalendar";
  version = "7.2.0";

  src = fetchFromGitHub {
    owner = "collective";
    repo = "icalendar";
    tag = "v${version}";
    hash = "sha256-0NKNbWigZ3BOfKBM8Q+XrOdoFBOF5Lu4XujJcYCMuMw=";
  };

  nativeBuildInputs = [
    pyprojectVersionPatchHook
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    python-dateutil
    tzdata
  ]
  ++ lib.optionals (pythonOlder "3.13") [
    # typing.TypeIs arrived in Python 3.13.
    typing-extensions
  ];

  disabledTests = [
    # AssertionError: assert {'Atlantic/Jan_Mayen'} == {'Arctic/Longyearbyen'}
    "test_dateutil_timezone_is_matched_with_tzname"
    "test_docstring_of_python_file"
  ];

  enabledTestPaths = [ "src/icalendar" ];
  pyproject = true;

  meta = {
    description = "Parser/generator of iCalendar files";
    homepage = "https://github.com/collective/icalendar";
    changelog = "https://github.com/collective/icalendar/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ olcai ];
    mainProgram = "icalendar";
  };
}
