{
  lib,
  fetchFromGitHub,
  ffmpeg,
  gitUpdater,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "vr-reversal";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "dfaker";
    repo = "vr-reversal";
    rev = "v${version}";
    sha256 = "1wn2ngcvn7wcsl3kmj782x5q9130qw951lj6ilrkafp6q6zscpqr";
  };

  # reset_rot is only available in ffmpeg 5.0, see 5bcc61ce87922ecccaaa0bd303a7e195929859a8
  postPatch = lib.optionalString (lib.versionOlder ffmpeg.version "5.0") ''
    substituteInPlace 360plugin.lua --replace-fail ":reset_rot=1:" ":"
  '';

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp -r 360plugin.lua $out/share/mpv/scripts/
  '';

  dontBuild = true;
  passthru.scriptName = "360plugin.lua";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Script for mpv to play VR video with optional saving of head tracking data";
    homepage = "https://github.com/dfaker/VR-reversal";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ schnusch ];
    platforms = lib.platforms.all;
  };
}
