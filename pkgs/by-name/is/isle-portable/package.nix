{
  lib,
  _7zz,
  callPackage,
  makeBinaryWrapper,
  requireFile,
  runCommand,
  symlinkJoin,
  writeText,
  isle-portable-unwrapped ? callPackage ./unwrapped.nix { },
}:
let
  legoIslandIso = requireFile {
    hash = "sha256-pefu/XcvGKcWYzaFldWeFEYdc7OUBgbmlgWyH2CnZec=";
    message = "ISO file of Lego Island 1.1";
    name = "LEGO_ISLANDI.ISO";
  };

  unpackedIso = runCommand "LEGO_ISLANDI-unpacked" { nativeBuildInputs = [ _7zz ]; } ''
    mkdir "$out"
    7zz x ${legoIslandIso} -o"$out"
  '';
in
symlinkJoin (
  finalAttrs:
  let
    # INI file with the LEGO Island Disk files in it
    iniWithDisk = lib.recursiveUpdate finalAttrs.passthru.iniConfig {
      isle = {
        cdpath = "${unpackedIso}";
        diskpath = "${unpackedIso}/DATA/disk";
      };
    };

    # Properly quoted INI file
    quotedIni = lib.mapAttrsRecursiveCond (as: (!lib.isDerivation as)) (
      _: value: ''"${toString value}"''
    ) iniWithDisk;

    # Make a config ini file
    iniFile = writeText "isle.ini" (lib.generators.toINI { } quotedIni);
  in
  {
    inherit (isle-portable-unwrapped) version;
    pname = "isle-portable-wrapped";

    nativeBuildInputs = [
      makeBinaryWrapper
    ];

    postBuild = ''
      wrapProgram "$out/bin/isle" \
        --add-flags "--ini ${iniFile}"
    '';

    paths = [
      isle-portable-unwrapped
    ];

    passthru.iniConfig = {
      extensions = {
        "si loader" = "false";
        "texture loader" = "false";
      };

      isle = {
        "3dsound" = "true";
        "anisotropic" = "";
        "back buffers in video ram" = "-1";
        cdpath = null;
        "cursor sensitivity" = "4.000000";
        diskpath = null;
        "exclusive framerate" = "60";
        "exclusive full screen" = "true";
        "exclusive x resolution" = "640";
        "exclusive y resolution" = "480";
        "flip surfaces" = "false";
        "frame delta" = "10";
        "full screen" = "true";
        "haptic" = "true";
        "horizontal resolution" = "640";
        "island quality" = "2";
        "island texture" = "1";
        "max allowed extras" = "20";
        "max lod" = "3.600000";
        mediapath = isle-portable-unwrapped;
        "msaa" = "0";
        "music" = "true";
        savepath = "~/.local/share/isledecomp/isle";
        "touch scheme" = "2";
        "transition type" = "3";
        "vertical resolution" = "480";
        "wide view angle" = "true";
      };
    };

    passthru.unwrapped = isle-portable-unwrapped;
    meta = removeAttrs isle-portable-unwrapped.meta [ "position" ];
  }
)
