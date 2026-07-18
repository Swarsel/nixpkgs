{
  lib,
  fetchFromGitHub,
  gettext,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ibus-theme-tools";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "IBus-Theme-Tools";
    rev = "v${finalAttrs.version}";
    sha256 = "0i8vwnikwd1bfpv4xlgzc51gn6s18q58nqhvcdiyjzcmy3z344c2";
  };

  buildInputs = [ gettext ];
  # No test.
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    tinycss2
    pygobject3
  ];

  pyproject = true;
  pythonImportsCheck = [ "ibus_theme_tools" ];

  meta = {
    description = "Generate the IBus GTK or GNOME Shell theme from existing themes";
    homepage = "https://github.com/openSUSE/IBus-Theme-Tools";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ hollowman6 ];
    mainProgram = "ibus-theme-tools";
  };
})
