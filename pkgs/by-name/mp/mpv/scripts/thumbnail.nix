{
  lib,
  fetchFromGitHub,
  buildLua,
  gitUpdater,
  python3,
}:

buildLua rec {
  pname = "mpv-thumbnail-script";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "marzzzello";
    repo = "mpv_thumbnail_script";
    rev = version;
    sha256 = "sha256-nflavx25skLj9kitneL6Uz3zI2DyMMhQC595npofzbQ=";
  };

  postPatch = "patchShebangs concat_files.py";
  nativeBuildInputs = [ python3 ];
  dontBuild = false;
  extraScriptsToCopy = [ "mpv_thumbnail_script_server.lua" ];
  extraScriptsToLoad = [ "mpv_thumbnail_script_server.lua" ];
  scriptPath = "mpv_thumbnail_script_client_osc.lua";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Lua script to show preview thumbnails in mpv's OSC seekbar";
    homepage = "https://github.com/marzzzello/mpv_thumbnail_script";
    changelog = "https://github.com/marzzzello/mpv_thumbnail_script/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ thegu5 ];
    platforms = lib.platforms.all;
  };
}
