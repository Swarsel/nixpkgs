{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  python3,
}:
let
  name = "crosspatch";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "NickPlayzGITHUB";
    repo = "CrossPatch";
    tag = version;
    hash = "sha256-Ux+tLP5Hv8ecnuITMqLiuX0YtF2ENZ7ezi2gNKfuNcM=";
  };

  python = python3.withPackages (ps: [
    ps.patool
    ps.py7zr
    ps.pyqtdarktheme
    ps.pyside6
    ps.rarfile
    ps.requests
  ]);

  parser = buildDotnetModule rec {
    inherit version src;
    pname = "crosspatch-parser";
    nugetDeps = ./dependencies.json;
    sourceRoot = "${src.name}/tools/CrossPatchParser";
    meta.mainProgram = "CrossPatchParser";
  };
in
stdenv.mkDerivation {
  inherit version src;
  pname = name;

  postPatch = ''
    mkdir "$out"
    cp -r "$src/src" "$out/src"
    substituteInPlace "$out/src/PakInspector.py" --replace 'possible_paths = _possible_parser_paths()' 'possible_paths = ["${lib.getExe parser}"]'
  '';

  nativeBuildInputs = [ copyDesktopItems ];
  buildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild
    mkdir -p "$out/bin"
    makeWrapper "${lib.getExe python}" "$out/bin/crosspatch" --add-flag "$out/src/CrossPatch.py"
    runHook postBuild
  '';

  desktopItems = lib.singleton (makeDesktopItem {
    inherit name;
    desktopName = "CrossPatch";
    exec = "crosspatch";
  });

  meta = {
    description = "A mod Manager for Sonic Racing: CrossWorlds";
    homepage = "https://github.com/NickPlayzGITHUB/CrossPatch";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ luna-the-tuna ];
    platforms = lib.platforms.linux;
    mainProgram = "crosspatch";
  };
}
