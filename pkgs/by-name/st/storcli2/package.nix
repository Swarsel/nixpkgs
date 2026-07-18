{
  lib,
  fetchzip,
  rpmextract,
  stdenvNoCC,
  testers,
}:
stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    majVer = "8";
    minVer = "11";
    relPhs = "14";
    verCode = "00" + majVer + ".00" + minVer + ".0000.00" + relPhs;
  in
  {
    pname = "storcli";
    version = majVer + "." + minVer;

    src = fetchzip {
      url = "https://docs.broadcom.com/docs-and-downloads/host-bus-adapters/host-bus-adapters-common-files/sas_sata_nvme_24g_p${finalAttrs.version}/StorCLI_Avenger_${finalAttrs.version}-${verCode}.zip";
      hash = "sha256-vztV+Jp+p6nU4q7q8QQIkuL30QsoGj2tyIZp87luhH8=";
    };

    nativeBuildInputs = [ rpmextract ];

    installPhase = ''
      install -D ./opt/MegaRAID/storcli2/storcli2 $out/bin/storcli2
    '';

    dontBuild = true;
    dontConfigure = true;
    # Not needed because the binary is statically linked
    dontFixup = false;
    dontPatch = true;

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
        rpmextract $src/Avenger_StorCLI/${platform}/storcli2-${verCode}-1.*.rpm
      '';

    passthru.tests = testers.testVersion {
      version = verCode;
      command = "${finalAttrs.meta.mainProgram} v";
      package = finalAttrs.finalPackage;
    };

    meta = {
      description = "Storage Command Line Tool";
      # Unfortunately there is no better page for this.
      # Filter for downloads, set 100 items per page. Sort by newest does not work.
      # Then search manually for the latest version.
      homepage = "https://www.broadcom.com/support/download-search?pg=&pf=Host+Bus+Adapters&pn=&pa=&po=&dk=storcli2&pl=&l=false";
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = with lib.maintainers; [ edwtjo ];

      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      mainProgram = "storcli2";
    };
  }
)
