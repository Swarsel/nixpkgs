{
  lib,
  fetchzip,
  rpmextract,
  stdenvNoCC,
  testers,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "storcli";
  version = "7.3103.00";

  src = fetchzip {
    url = "https://docs.broadcom.com/docs-and-downloads/host-bus-adapters/host-bus-adapters-common-files/sas_sata_nvme_12g_p${finalAttrs.phase}/STORCLI_SAS3.5_P${finalAttrs.phase}.zip";
    hash = "sha256-bOlIChZi2eWpc5QA+wXBQA4s+o/MVLVWsligjDpUXEU=";
  };

  nativeBuildInputs = [ rpmextract ];

  installPhase = ''
    install -D ./opt/MegaRAID/storcli/storcli64 $out/bin/storcli64
    ln -s storcli64 $out/bin/storcli
  '';

  dontBuild = true;
  dontConfigure = true;
  # Not needed because the binary is statically linked
  dontFixup = true;
  dontPatch = true;
  phase = "32";

  unpackPhase =
    let
      inherit (stdenvNoCC.hostPlatform) system;
      platforms = {
        aarch64-linux = "ARM/Linux";
        x86_64-linux = "Linux";
      };
      platform = platforms.${system} or (throw "unsupported system: ${system}");
    in
    ''
      rpmextract $src/univ_viva_cli_rel/Unified_storcli_all_os/${platform}/storcli-00${finalAttrs.version}00.0000-1.*.rpm
    '';

  passthru.tests = testers.testVersion {
    version = "00${finalAttrs.version}00.0000";
    command = "${finalAttrs.meta.mainProgram} -v";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Storage Command Line Tool";
    # Unfortunately there is no better page for this.
    # Filter for downloads, set 100 items per page. Sort by newest does not work.
    # Then search manually for the latest version.
    homepage = "https://www.broadcom.com/support/download-search?pg=&pf=Host+Bus+Adapters&pn=&pa=&po=&dk=storcli&pl=&l=false";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ panicgh ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "storcli";
  };
})
