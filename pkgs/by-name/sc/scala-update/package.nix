{
  lib,
  buildGraalvmNativeImage,
  coursier,
  stdenvNoCC,
}:

buildGraalvmNativeImage (finalAttrs: {
  pname = "scala-update";
  version = "0.2.2";
  src = "${finalAttrs.finalPackage.passthru.deps}/share/java/scala-update_2.13-${finalAttrs.version}.jar";
  buildInputs = [ finalAttrs.finalPackage.passthru.deps ];

  buildPhase = ''
    runHook preBuild

    native-image ''${nativeImageArgs[@]} -cp $(JARS=("${finalAttrs.finalPackage.passthru.deps}/share/java"/*.jar); IFS=:; echo "''${JARS[*]}")

    runHook postBuild
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/scala-update --version | grep -q "${finalAttrs.version}"

    runHook postInstallCheck
  '';

  extraNativeImageBuildArgs = [
    "--no-fallback"
    "--enable-url-protocols=https"
    "update.Main"
  ];

  passthru.deps = stdenvNoCC.mkDerivation {
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${lib.getExe coursier} fetch io.github.kitlangton:scala-update_2.13:${finalAttrs.version} > deps
      mkdir -p $out/share/java
      cp $(< deps) $out/share/java/
    '';

    name = "scala-update-deps-${finalAttrs.version}";
    outputHash = "kNnFzzHn+rFq4taqRYjBYaDax0MHW+vIoSFVN3wxA8M=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  meta = {
    description = "Update your Scala dependencies interactively";
    homepage = "https://github.com/kitlangton/scala-update";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.rtimush ];
    mainProgram = "scala-update";
  };
})
