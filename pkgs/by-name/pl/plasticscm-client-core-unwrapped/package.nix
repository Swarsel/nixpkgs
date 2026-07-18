{
  lib,
  fetchurl,
  common-updater-scripts,
  curl,
  dpkg,
  jc,
  jq,
  makeWrapper,
  stdenvNoCC,
  writeShellApplication,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plasticscm-client-core-unwrapped";
  version = "11.0.16.10216";

  src = fetchurl {
    url = "https://www.plasticscm.com/plasticrepo/stable/debian/amd64/plasticscm-client-core_${finalAttrs.version}_amd64.deb";
    hash = "sha256-5Hmhb6DdJOohCj3LBn7Mo8Kad+MEjlfIKEBlNnujBY0=";
    downloadToTemp = true;
    nativeBuildInputs = [ dpkg ];

    postFetch = ''
      mkdir -p $out
      dpkg-deb --fsys-tarfile $downloadedFile | tar --extract --directory=$out
      rm -rf $out/usr/share/doc
    '';

    recursiveHash = true;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r opt usr/{share,bin} $out

    runHook postInstall
  '';

  dontFixup = true;

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-plasticscm-client-core-unwrapped";

    runtimeInputs = [
      common-updater-scripts
      curl
      dpkg
      jc
      jq
    ];

    text = ''
      version="$(curl -sSL https://www.plasticscm.com/plasticrepo/stable/debian/Packages |
        jc --pkg-index-deb |
        jq -r '[.[] | select(.package == "plasticscm-client-core")] | sort_by(.version) | last | .version')"

      update-source-version --ignore-same-hash plasticscm-client-core-unwrapped "$version"
    '';
  });

  meta = {
    description = "SCM by Unity for game development";
    homepage = "https://www.plasticscm.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ musjj ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cm";
  };
})
