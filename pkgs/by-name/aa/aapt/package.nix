{
  lib,
  autoPatchelfHook,
  fetchzip,
  libcxx,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "aapt";
  version = "8.13.2-14304508";

  src =
    let
      urlAndHash =
        if stdenvNoCC.hostPlatform.isLinux then
          {
            hash = "sha256-eiNY58ueDpcyKvAteRuKFVr3r22kOhwSADkaH3CRwKw=";
            url = "https://dl.google.com/android/maven2/com/android/tools/build/aapt2/${finalAttrs.version}/aapt2-${finalAttrs.version}-linux.jar";
          }
        else if stdenvNoCC.hostPlatform.isDarwin then
          {
            hash = "sha256-RI/S2oXMSvipALRfeRTsiXUh130/b8iP+EO0yltd7x0=";
            url = "https://dl.google.com/android/maven2/com/android/tools/build/aapt2/${finalAttrs.version}/aapt2-${finalAttrs.version}-osx.jar";
          }
        else
          throw "Unsupport platform: ${stdenvNoCC.system}";
    in
    fetchzip (
      urlAndHash
      // {
        extension = "zip";
        stripRoot = false;
      }
    );

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ libcxx ];

  installPhase = ''
    runHook preInstall

    install -D aapt2 $out/bin/aapt2

    runHook postInstall
  '';

  meta = {
    description = "Build tool that compiles and packages Android app's resources";
    homepage = "https://developer.android.com/tools/aapt2";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ linsui ];
    platforms = lib.platforms.darwin ++ [ "x86_64-linux" ];
    mainProgram = "aapt2";
    teams = [ lib.teams.android ];
  };
})
