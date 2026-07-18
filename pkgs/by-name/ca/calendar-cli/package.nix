{
  lib,
  fetchFromGitHub,
  nixosTests,
  perl,
  python3,
  radicale,
  versionCheckHook,
  which,
  xandikos,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "calendar-cli";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "pycalendar";
    repo = "calendar-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5qPBHwOPW/HsmO/jBMyq6ROb23JYfJ/XLWmHwgb5kPY=";
  };

  postPatch = ''
    patchShebangs tests
    substituteInPlace tests/test_calendar-cli.sh \
      --replace-fail "../bin/calendar-cli.py" "$out/bin/calendar-cli"
  '';

  nativeCheckInputs = [
    perl
    (python3.pkgs.toPythonModule (radicale.override { inherit python3; }))
    versionCheckHook
    which
    xandikos
  ];

  checkPhase = ''
    runHook preCheck
    runHook preInstallCheck

    pushd tests
    ./test_calendar-cli.sh
    popd

    runHook postCheck
    runHook postInstallCheck
  '';

  build-system = with python3.pkgs; [
    hatch-vcs
    hatchling
  ];

  dependencies = with python3.pkgs; [
    icalendar
    caldav
    pytz
    pyyaml
    tzlocal
    click
    six
    vobject
  ];

  pyproject = true;

  passthru.tests = {
    inherit (nixosTests) radicale;
  };

  meta = {
    description = "Simple command-line CalDav client";
    homepage = "https://github.com/pycalendar/calendar-cli";
    changelog = "https://github.com/pycalendar/calendar-cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "calendar-cli";
  };
})
