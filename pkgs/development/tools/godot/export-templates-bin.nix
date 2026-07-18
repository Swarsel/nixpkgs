{
  lib,
  fetchurl,
  godot,
  hash,
  stdenvNoCC,
  unzip,
  version,
  withMono ? false,
}:
# Export templates is necessary for setting up Godot engine, it's used when exporting projects.
# Godot applications/games packages needs to reference export templates.
# Export templates version should be kept in sync with Godot version.
# https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html#export-templates
let
  self = stdenvNoCC.mkDerivation {
    pname = "godot-export-templates${lib.optionalString withMono "-mono"}-bin";
    version = version;

    src = fetchurl {
      inherit hash;
      url = "https://github.com/godotengine/godot/releases/download/${version}/Godot_v${version}${lib.optionalString withMono "_mono"}_export_templates.tpz";
    };

    strictDeps = true;

    nativeBuildInputs = [
      unzip
    ];

    installPhase = ''
      templates="$out"/share/godot/export_templates
      mkdir -p "$templates"
      read version < templates/version.txt
      mv templates "$templates/$version"
    '';

    __structuredAttrs = true;

    unpackPhase = ''
      runHook preUnpack
      unzip -q "$src"
      runHook postUnpack
    '';

    meta = {
      inherit (godot.meta)
        changelog
        description
        homepage
        license
        maintainers
        ;

      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };
in
self
