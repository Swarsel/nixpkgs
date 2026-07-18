{
  lib,
  fetchFromGitHub,
  buildLua,
  ffmpeg,
  unstableGitUpdater,
}:

let
  camelToKebab =
    let
      inherit (lib.strings) match stringAsChars toLower;
      isUpper = match "[A-Z]";
    in
    stringAsChars (c: if isUpper c != null then "-${toLower c}" else c);

  mkScript =
    name: args:
    let
      self = rec {
        pname = camelToKebab name;
        version = "0-unstable-2025-11-01";

        src = fetchFromGitHub {
          owner = "occivink";
          repo = "mpv-scripts";
          rev = "01f3e99558915bb715b614d7f4b052230360eb21";
          hash = "sha256-v3TGsCzSg+a1vrOgI5NbTVf8Bh/iMRRgwMy194sNq1Y=";
        };

        # Sadly needed to make `common-updaters` work here
        pos = builtins.unsafeGetAttrPos "version" self;
        scriptPath = "scripts/${pname}.lua";
        passthru.updateScript = unstableGitUpdater { };

        meta = {
          homepage = "https://github.com/occivink/mpv-scripts";
          license = lib.licenses.unlicense;
          maintainers = with lib.maintainers; [ nicoo ];
        };
      };
    in
    buildLua (lib.attrsets.recursiveUpdate self args);
in
lib.recurseIntoAttrs (
  lib.mapAttrs (name: lib.makeOverridable (mkScript name)) {

    blacklistExtensions.meta.description = "Automatically remove playlist entries based on their extension";
    # Usage: `pkgs.mpv.override { scripts = [ pkgs.mpvScripts.seekTo ]; }`
    crop.meta.description = "Crop the current video in a visual manner";

    encode = {
      postPatch = ''
        substituteInPlace scripts/encode.lua \
            --replace-fail '"ffmpeg"' '"${lib.getExe ffmpeg}"'
      '';

      meta.description = "Make an extract of the video currently playing using ffmpeg";
    };

    seekTo.meta.description = "Mpv script for seeking to a specific position";
  }
)
