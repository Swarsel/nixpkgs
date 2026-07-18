{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  explorerscript,
  gobject-introspection,
  gtk3,
  gtksourceview4,
  ndspy,
  nest-asyncio,
  pmdsky-debug-py,
  pycairo,
  pygobject3,
  pygtkspellcheck,
  range-typed-integers,
  setuptools,
  skytemple-files,
  skytemple-icons,
  skytemple-ssb-emulator,
  wrapGAppsHook3,
}:

buildPythonPackage rec {
  pname = "skytemple-ssb-debugger";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "skytemple-ssb-debugger";
    rev = version;
    hash = "sha256-J4UAxNxB2QSaTW1r1xL9wKGTISv0H4RdDnRiZp4idts=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gtksourceview4
  ];

  doCheck = false; # requires Pokémon Mystery Dungeon ROM
  build-system = [ setuptools ];

  dependencies = [
    explorerscript
    ndspy
    nest-asyncio
    pmdsky-debug-py
    pycairo
    pygobject3
    pygtkspellcheck
    range-typed-integers
    skytemple-files
    skytemple-icons
    skytemple-ssb-emulator
  ];

  pyproject = true;
  pythonImportsCheck = [ "skytemple_ssb_debugger" ];

  meta = {
    description = "Script Engine Debugger for Pokémon Mystery Dungeon Explorers of Sky";
    homepage = "https://github.com/SkyTemple/skytemple-ssb-debugger";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
    mainProgram = "skytemple-ssb-debugger";
  };
}
