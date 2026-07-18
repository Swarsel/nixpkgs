{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  comicon,
  feedparser,
  filetype,
  lxml,
  natsort,
  nix-update-script,
  pillow,
  poetry-core,
  pyside6,
  python-slugify,
  requests,
  typer,
}:

buildPythonPackage rec {
  pname = "mandown";
  version = "1.12.2";

  src = fetchFromGitHub {
    owner = "potatoeggy";
    repo = "mandown";
    tag = "v${version}";
    hash = "sha256-kbzh6qbex3PzdE53rx9Sxff1lhh1yYjehdEJ9Srq5gY=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    beautifulsoup4
    comicon
    feedparser
    filetype
    lxml
    natsort
    pillow
    python-slugify
    requests
    typer
  ];

  optional-dependencies = {
    gui = [ pyside6 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mandown" ];

  pythonRelaxDeps = [
    "beautifulsoup4"
    "lxml"
    "pillow"
    "typer"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Comic/manga/webtoon downloader and CBZ/EPUB/MOBI/PDF converter";
    homepage = "https://github.com/potatoeggy/mandown";
    changelog = "https://github.com/potatoeggy/mandown/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ Scrumplex ];
  };
}
