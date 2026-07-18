{
  lib,
  fetchFromGitLab,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "undertime";
  version = "4.3.1";

  src = fetchFromGitLab {
    owner = "anarcat";
    repo = "undertime";
    tag = finalAttrs.version;
    hash = "sha256-TOrsQIi+ZcUQUGhb+iX8seuwNfKrrBL2DIcLK9wyjn0=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    dateparser
    ephem
    pytz
    pyyaml
    termcolor
    tabulate
    tzlocal
  ];

  pyproject = true;

  meta = {
    description = "Pick a meeting time across timezones from the commandline";

    longDescription = ''
      Undertime draws a simple 24 hour table of matching times across
      different timezones or cities, outlining waking hours. This allows
      picking an ideal meeting date across multiple locations for teams
      working internationally.
    '';

    homepage = "https://gitlab.com/anarcat/undertime";
    changelog = "https://gitlab.com/anarcat/undertime/-/raw/${finalAttrs.version}/debian/changelog";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ dvn0 ];
    mainProgram = "undertime";
  };
})
