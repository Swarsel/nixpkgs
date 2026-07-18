{
  lib,
  buildEnv,
  df-games,
  latestVersion,
  legends-browser,
  stdenvNoCC,
  themes,
  versionToName,
  dfVersion ? latestVersion,
  # This package should, at any given time, provide an opinionated "optimal"
  # DF experience. It's the equivalent of the Lazy Newbie Pack, that is, and
  # should contain every utility available unless you disable them.
  enableDFHack ? stdenvNoCC.hostPlatform.isLinux,
  enableDwarfTherapist ? true,
  enableFPS ? false,
  # General config options:
  enableIntro ? true,
  enableLegendsBrowser ? true,
  enableSound ? true,
  enableSoundSense ? true,
  enableStoneSense ? true,
  enableTWBT ? enableDFHack,
  enableTextMode ? false,
  enableTruetype ? null, # defaults to 24, see init.txt
  theme ? themes.phoebus,
}:

let
  inherit (lib)
    getAttr
    hasAttr
    licenses
    maintainers
    optional
    platforms
    ;

  dfGame = versionToName dfVersion;
  dwarf-fortress =
    if hasAttr dfGame df-games then
      getAttr dfGame df-games
    else
      throw "Unknown Dwarf Fortress version: ${dfVersion}";
  dwarf-therapist = dwarf-fortress.dwarf-therapist;

  mainProgram = if enableDFHack then "dfhack" else "dwarf-fortress";
in
buildEnv {
  pname = "dwarf-fortress-full";
  version = dfVersion;

  paths = [
    (dwarf-fortress.override {
      inherit
        enableDFHack
        enableTWBT
        enableSoundSense
        enableStoneSense
        theme
        enableIntro
        enableTruetype
        enableFPS
        enableTextMode
        enableSound
        ;
    })
  ]
  ++ optional enableDwarfTherapist dwarf-therapist
  ++ optional enableLegendsBrowser legends-browser;

  meta = {
    inherit mainProgram;
    description = "Opinionated wrapper for Dwarf Fortress";
    homepage = "https://github.com/NixOS/nixpkgs/";
    license = licenses.mit;

    maintainers = with maintainers; [
      Baughn
      numinit
    ];

    platforms = platforms.all;
  };
}
