{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rofi-mpd";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "JakeStanger";
    repo = "Rofi_MPD";
    rev = "v${finalAttrs.version}";
    sha256 = "0jabyn6gqh8ychn2a06xws3avz0lqdnx3qvqkavfd2xr6sp2q7lg";
  };

  # upstream doesn't contain a test suite
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    mutagen
    python-mpd2
    toml
    appdirs
  ];

  pyproject = true;

  meta = {
    description = "Rofi menu for interacting with MPD written in Python";
    homepage = "https://github.com/JakeStanger/Rofi_MPD";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jakestanger ];
    platforms = lib.platforms.all;
    mainProgram = "rofi-mpd";
  };
})
