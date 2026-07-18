{
  lib,
  fetchFromGitHub,
  # runtime
  babel,
  buildPythonPackage,
  fetchpatch,
  flask,
  # docs
  furo,
  jinja2,
  # build-system
  poetry-core,
  # tests
  pytest-mock,
  pytestCheckHook,
  pytz,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "flask-babel";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "python-babel";
    repo = "flask-babel";
    tag = "v${version}";
    hash = "sha256-NcwcMLGabWrjbFZhDU1MVWpqAm0prBlqHfTdLV7EqoI=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    # Fix list-translations() ordering in tests
    # https://github.com/python-babel/flask-babel/pull/242
    (fetchpatch {
      hash = "sha256-vhP/aSWaWpy1sVOJAcrLHJN/yrB+McWO9pkXDI9GeQ4=";
      url = "https://github.com/python-babel/flask-babel/pull/242/commits/999735d825ee2f94701da29bcf819ad70ee03499.patch";
    })
  ];

  nativeBuildInputs = [
    furo
    sphinxHook
  ];

  checkInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    babel
    flask
    jinja2
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_babel" ];

  meta = {
    description = "Adds i18n/l10n support to Flask applications";

    longDescription = ''
      Implements i18n and l10n support for Flask.
      This is based on the Python babel module as well as pytz both of which are
      installed automatically for you if you install this library.
    '';

    homepage = "https://github.com/python-babel/flask-babel";
    changelog = "https://github.com/python-babel/flask-babel/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ matejc ];
    teams = [ lib.teams.sage ];
  };
}
