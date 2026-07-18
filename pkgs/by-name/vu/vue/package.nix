{
  lib,
  stdenv,
  fetchurl,
  jre,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vue";
  version = "3.3.0";

  src = fetchurl {
    url = "http://releases.atech.tufts.edu/jenkins/job/VUE/116/deployedArtifacts/download/artifact.1";
    sha256 = "0yfzr80pw632lkayg4qfmwzrqk02y30yz8br7isyhmgkswyp5rnx";
  };

  installPhase = ''
    mkdir -p "$out"/{share/vue,bin}
    cp ${finalAttrs.src} "$out/share/vue/vue.jar"
    echo '#!${runtimeShell}' >> "$out/bin/vue"
    echo '${jre}/bin/java -jar "'"$out/share/vue/vue.jar"'" "$@"' >> "$out/bin/vue"
    chmod a+x "$out/bin/vue"
  '';

  dontUnpack = true;

  meta = {
    description = "Visual Understanding Environment - mind mapping software";
    license = lib.licenses.ecl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ raskin ];
    platforms = with lib.platforms; linux;
    mainProgram = "vue";
  };
})
