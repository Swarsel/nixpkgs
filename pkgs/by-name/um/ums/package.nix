{
  lib,
  stdenv,
  fetchurl,
  jdk17,
  libmediainfo,
  libzen,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ums";
  version = "13.2.1";

  src =
    let
      selectSystem =
        attrs:
        attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
      arch = selectSystem {
        aarch64-linux = "arm64";
        x86_64-linux = "x86_64";
      };
    in
    fetchurl {
      url = "mirror://sourceforge/project/unimediaserver/${finalAttrs.version}/UMS-${finalAttrs.version}-${arch}.tgz";

      hash = selectSystem {
        aarch64-linux = "sha256-9x1M1rZxwg65RdMmxQ2geeF0yXrukQ3dQPXKfQ2GRIw=";
        x86_64-linux = "sha256-MGi5S0jA9WVh7PuNei5hInUVZLcypJu8izwWJpDi42s=";
      };
    };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    cp -a . $out
    mkdir $out/bin
    mv $out/documentation /$out/doc

    # ums >= 9.0.0 ships its own JRE in the package. if we remove it, the `UMS.sh`
    # script will correctly fall back to the JRE specified by JAVA_HOME
    rm -rf $out/jre17

    makeWrapper $out/UMS.sh $out/bin/ums \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libzen
          libmediainfo
        ]
      } \
      --set JAVA_HOME ${jdk17}

    runHook postInstall
  '';

  meta = {
    description = "Universal Media Server: a DLNA-compliant UPnP Media Server";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      thall
      snicket2100
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ums";
  };
})
