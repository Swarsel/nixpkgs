{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  icalendar,
  pygments,
  pytest-click,
  pytestCheckHook,
  pytz,
  restructuredtext-lint,
  setuptools,
  tzdata,
}:

buildPythonPackage rec {
  pname = "x-wr-timezone";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "niccokunzmann";
    repo = "x-wr-timezone";
    tag = "v${version}";
    hash = "sha256-Llpe3Z0Yfd0vRgx95D4YVrnNJk0g/VqPuNvtUrUpFk0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    restructuredtext-lint
    pygments
    pytz
    pytest-click
  ];

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  build-system = [ setuptools ];

  dependencies = [
    click
    icalendar
    tzdata
  ];

  pyproject = true;
  pythonImportsCheck = [ "x_wr_timezone" ];

  meta = {
    description = "Convert calendars using X-WR-TIMEZONE to standard ones";
    homepage = "https://github.com/niccokunzmann/x-wr-timezone";
    changelog = "https://github.com/niccokunzmann/x-wr-timezone/blob/${src.tag}/README.rst#changelog";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
