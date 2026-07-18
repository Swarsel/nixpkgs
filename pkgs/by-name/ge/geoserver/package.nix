{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  jre,
  makeWrapper,
  nixosTests,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "geoserver";
  version = "2.28.4";

  src = fetchurl {
    url = "mirror://sourceforge/geoserver/GeoServer/${finalAttrs.version}/geoserver-${finalAttrs.version}-bin.zip";
    hash = "sha256-bQECI2MEk8OcALk21bbv/V/yNbOrHKlhcpoVy37U1i0=";
  };

  patches = [
    # set GEOSERVER_DATA_DIR to current working directory if not provided
    ./data-dir.patch
  ];

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase =
    let
      inputs = finalAttrs.buildInputs or [ ];
      ldLibraryPathEnvName =
        if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in
    ''
      runHook preInstall
      mkdir -p $out/share/geoserver
      cp -r . $out/share/geoserver
      rm -fr $out/share/geoserver/bin/*.bat

      makeWrapper $out/share/geoserver/bin/startup.sh $out/bin/geoserver-startup \
        --prefix PATH : "${lib.makeBinPath inputs}" \
        --prefix ${ldLibraryPathEnvName} : "${lib.makeLibraryPath inputs}" \
        --set JAVA_HOME "${jre}" \
        --set GEOSERVER_HOME "$out/share/geoserver"
      makeWrapper $out/share/geoserver/bin/shutdown.sh $out/bin/geoserver-shutdown \
        --prefix PATH : "${lib.makeBinPath inputs}" \
        --prefix ${ldLibraryPathEnvName} : "${lib.makeLibraryPath inputs}" \
        --set JAVA_HOME "${jre}" \
        --set GEOSERVER_HOME "$out/share/geoserver"
      runHook postInstall
    '';

  sourceRoot = ".";

  passthru =
    let
      geoserver = finalAttrs.finalPackage;
      extensions = lib.attrsets.filterAttrs (n: v: lib.isDerivation v) (callPackage ./extensions.nix { });
    in
    {
      tests.geoserver = nixosTests.geoserver;
      updateScript = ./update.sh;

      withExtensions =
        selector:
        let
          selectedExtensions = selector extensions;
        in
        geoserver.overrideAttrs (
          finalAttrs: previousAttrs: {
            pname = previousAttrs.pname + "-with-extensions";

            buildInputs = lib.lists.unique (
              (previousAttrs.buildInputs or [ ]) ++ lib.lists.concatMap (drv: drv.buildInputs) selectedExtensions
            );

            postInstall = (previousAttrs.postInstall or "") + ''
              for extension in ${toString selectedExtensions} ; do
                cp -r $extension/* $out
                # Some files are the same for all/several extensions. We allow overwriting them again.
                chmod -R +w $out
              done
            '';
          }
        );
    };

  meta = {
    description = "Open source server for sharing geospatial data";
    homepage = "https://geoserver.org/";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    teams = [ lib.teams.geospatial ];
  };
})
