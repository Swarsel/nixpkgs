{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "cambrinary";
  version = "unstable-2023-07-16";

  src = fetchFromGitHub {
    owner = "xueyuanl";
    repo = "cambrinary";
    rev = "f0792ef70654a48a7677b6e1a7dee454b2c0971c";
    hash = "sha256-wDcvpKAY/6lBjO5h3qKH3+Y2G2gm7spcKCXFMt/bAtE=";
  };

  build-system = with python3Packages; [
    flit
  ];

  dependencies = with python3Packages; [
    aiohttp
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "cambrinary" ];

  meta = {
    description = "Cambridge dictionary in a terminal";
    homepage = "https://github.com/xueyuanl/cambrinary";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "cambrinary";
  };
}
