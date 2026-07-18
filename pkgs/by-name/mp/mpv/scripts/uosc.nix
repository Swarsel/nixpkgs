{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildLua,
  gitUpdater,
  makeFontsConf,
}:

buildLua (finalAttrs: {
  pname = "uosc";
  version = "5.12.0";

  src = fetchFromGitHub {
    owner = "tomasklaen";
    repo = "uosc";
    rev = finalAttrs.version;
    hash = "sha256-vSs6X++WIM9NfTvcsJgwiKmTuU0eu3i3cffsdCVSyV4=";
  };

  # the script uses custom "texture" fonts as the background for ui elements.
  # In order for mpv to find them, we need to adjust the fontconfig search path.
  postInstall = "cp -r src/fonts $out/share";
  scriptPath = "src/uosc";

  tools = buildGoModule {
    inherit (finalAttrs) version src;
    pname = "uosc-bin";
    vendorHash = "sha256-oRXChHeVQj6nXvKOVV125sM8wD33Dxxv0r/S7sl6SxQ=";
  };

  passthru.extraWrapperArgs = [
    "--set"
    "FONTCONFIG_FILE"
    (toString (makeFontsConf {
      fontDirectories = [ "${finalAttrs.finalPackage}/share/fonts" ];
    }))
    "--set"
    "MPV_UOSC_ZIGGY"
    (lib.getExe' finalAttrs.tools "ziggy")
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Feature-rich minimalist proximity-based UI for MPV player";
    homepage = "https://github.com/tomasklaen/uosc";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ apfelkuchen6 ];
  };
})
