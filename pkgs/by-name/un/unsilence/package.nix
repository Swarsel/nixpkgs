{
  lib,
  fetchFromGitHub,
  ffmpeg,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "unsilence";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "lagmoellertim";
    repo = "unsilence";
    rev = version;
    hash = "sha256-M4Ek1JZwtr7vIg14aTa8h4otIZnPQfKNH4pZE4GpiBQ=";
  };

  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    rich
  ];

  makeWrapperArgs = [
    "--suffix PATH : ${lib.makeBinPath [ ffmpeg ]}"
  ];

  pyproject = true;
  pythonImportsCheck = [ "unsilence" ];
  pythonRelaxDeps = [ "rich" ];

  meta = {
    description = "Console Interface and Library to remove silent parts of a media file";
    homepage = "https://github.com/lagmoellertim/unsilence";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ esau79p ];
    mainProgram = "unsilence";
  };
}
