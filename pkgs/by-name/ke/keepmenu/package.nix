{
  lib,
  fetchFromGitHub,
  dmenu,
  python3Packages,
  xdotool,
  xsel,
  xvfb-run,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "keepmenu";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "firecat53";
    repo = "keepmenu";
    rev = finalAttrs.version;
    hash = "sha256-Kzt2RqyYvOWnbkflwTHzlnpUaruVQvdGys57DDpH9o8=";
  };

  postPatch = ''
    substituteInPlace tests/keepmenu-config.ini tests/tests.py \
      --replace "/usr/bin/dmenu" "dmenu"
  '';

  nativeBuildInputs = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  propagatedBuildInputs = with python3Packages; [
    pykeepass
    pynput
  ];

  nativeCheckInputs = [
    dmenu
    xdotool
    xsel
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck

    xvfb-run python tests/tests.py

    runHook postCheck
  '';

  pyproject = true;
  pythonImportsCheck = [ "keepmenu" ];

  meta = {
    description = "Dmenu/Rofi frontend for Keepass databases";
    homepage = "https://github.com/firecat53/keepmenu";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ elliot ];
    platforms = lib.platforms.linux;
    mainProgram = "keepmenu";
  };
})
