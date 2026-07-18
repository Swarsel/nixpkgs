{
  lib,
  stdenv,
  fetchFromGitHub,
  buildLua,
  curl,
  unstableGitUpdater,
  wl-clipboard,
  xclip,
}:
buildLua {
  pname = "videoclip";
  version = "0.2-unstable-2026-05-31";

  src = fetchFromGitHub {
    owner = "Ajatt-Tools";
    repo = "videoclip";
    rev = "d9a3e0966b238b824b86767956eb44a11ac367c6";
    hash = "sha256-NZaflGehxoIf9eY3/p9WrKXXQj3x6GDZ6iMLeu5BhPc=";
  };

  patchPhase = ''
    substituteInPlace platform.lua \
    --replace \'curl\' \'${lib.getExe curl}\' \
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    --replace xclip ${lib.getExe xclip} \
    --replace wl-copy ${lib.getExe' wl-clipboard "wl-copy"}
  '';

  scriptPath = ".";
  passthru.scriptName = "videoclip";

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
  };

  meta = {
    description = "Easily create videoclips with mpv";
    homepage = "https://github.com/Ajatt-Tools/videoclip";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ BatteredBunny ];
    platforms = lib.platforms.all;
  };
}
