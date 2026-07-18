{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ical2orgpy";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "ical2org-py";
    repo = "ical2org.py";
    tag = finalAttrs.version;
    hash = "sha256-vBi1WYXMuDFS/PnwFQ/fqN5+gIvtylXidfZklyd6LcI=";
  };

  nativeCheckInputs = with python3Packages; [
    freezegun
    pytestCheckHook
    pyyaml
    versionCheckHook
  ];

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    click
    icalendar
    pytz
    tzlocal
    recurring-ical-events
  ];

  pyproject = true;
  pythonImportsCheck = [ "ical2orgpy" ];
  pythonRemoveDeps = [ "future" ];

  meta = {
    description = "Converting ICAL file into org-mode format";
    homepage = "https://github.com/ical2org-py/ical2org.py";
    changelog = "https://github.com/ical2org-py/ical2org.py/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ StillerHarpo ];
    mainProgram = "ical2orgpy";
  };

})
