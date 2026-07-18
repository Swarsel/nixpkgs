{
  lib,
  fetchFromGitHub,
  mopidy,
  python3,
}:

let
  python = python3;
in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mopidy-ytmusic";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "jmcdo29";
    repo = "mopidy-ytmusic";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2o4fDtaIxRDvIiAGV/9qK/00BmYXasBUwW03fxFcDAU=";
  };

  postPatch = ''
    # only setup.py has up to date dependencies
    rm pyproject.toml
  '';

  nativeBuildInputs = with python.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = [
    (mopidy.override { pythonPackages = python.pkgs; })
    python.pkgs.ytmusicapi
    python.pkgs.pytube
  ];

  # has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "mopidy_ytmusic" ];

  meta = {
    description = "Mopidy extension for playing music from YouTube Music";
    homepage = "https://github.com/jmcdo29/mopidy-ytmusic";
    changelog = "https://github.com/jmcdo29/mopidy-ytmusic/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.nickhu ];
  };
})
