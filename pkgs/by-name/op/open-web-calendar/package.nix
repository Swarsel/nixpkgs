{
  lib,
  fetchPypi,
  nixosTests,
  python3,
  defaultSpecificationFile ? null,
}:

let
  python = python3;
in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "open-web-calendar";
  version = "1.51";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-r+7ZKdNOhjnjE1MBNAkni4Rrpx4DMRhUaP1Mmk5wzOo=";
    pname = "open_web_calendar";
  };

  # The Pypi tarball doesn't contain open_web_calendars/features
  postPatch = ''
    ln -s $PWD/features open_web_calendar/features
  '';

  nativeCheckInputs = with python.pkgs; [
    pytestCheckHook
    pytest-responses
  ];

  postInstall = lib.optionalString (defaultSpecificationFile != null) ''
    install -D ${defaultSpecificationFile} $out/$defaultSpecificationPath
  '';

  build-system = with python.pkgs; [
    hatchling
    hatch-vcs
    hatch-requirements-txt
  ];

  defaultSpecificationPath = "${python.sitePackages}/open_web_calendar/default_specification.yml";

  dependencies =
    with python.pkgs;
    [
      flask-allowed-hosts
      flask
      icalendar
      icalendar-compatibility
      cryptography
      bcrypt
      caldav
      requests
      requests-cache
      pyyaml
      recurring-ical-events
      gunicorn
      lxml
      beautifulsoup4
      lxml-html-clean
      pytz
      mergecal
    ]
    ++ requests.optional-dependencies.socks;

  enabledTestPaths = [ "open_web_calendar/test" ];
  pyproject = true;
  pythonImportsCheck = [ "open_web_calendar.app" ];

  passthru = {
    inherit python;

    tests = {
      inherit (nixosTests) open-web-calendar;
    };
  };

  meta = {
    description = "Highly customizable web calendar that can be embedded into websites using ICal source links";
    homepage = "https://open-web-calendar.quelltext.eu";

    changelog =
      let
        v = builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version;
      in
      "https://open-web-calendar.quelltext.eu/changelog/#v${v}";

    license = with lib.licenses; [
      gpl2Only
      cc-by-sa-40
      cc0
    ];

    maintainers = with lib.maintainers; [ erictapen ];
    platforms = lib.platforms.linux;
    mainProgram = "open-web-calendar";
  };
})
