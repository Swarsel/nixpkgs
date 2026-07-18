{
  lib,
  fetchFromGitHub,
  dbus,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "spotify-cli-linux";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "pwittchen";
    repo = "spotify-cli-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ko/as7wiBHawmyag9jFZqpPUZhb3p1+oYcl+26XyBZk=";
  };

  propagatedBuildInputs = with python3Packages; [
    lyricwikia
    jeepney
  ];

  preBuild = ''
    substituteInPlace spotifycli/spotifycli.py \
      --replace-fail dbus-send ${dbus}/bin/dbus-send
  '';

  # upstream has no code tests, but uses its "tests" for linting and formatting checks
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];
  disabled = !python3Packages.isPy3k;
  pyproject = true;

  meta = {
    description = "Command line interface to Spotify on Linux";
    homepage = "https://pwittchen.github.io/spotify-cli-linux/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.kmein ];
    platforms = lib.platforms.linux;
    mainProgram = "spotifycli";
  };
})
