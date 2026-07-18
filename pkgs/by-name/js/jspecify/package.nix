{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  jdk21,
  jre_minimal,
  nix-update,
  writeShellScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jspecify";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "jspecify";
    repo = "jspecify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WgVRaGm9lYhMeMM6QWUezXtUsXkaK/iPt1gj2koWNu8=";
  };

  nativeBuildInputs = [
    gradle
    jdk21
  ];

  # JSpecify's build.gradle reads JAVA_VERSION (defaults to 11). Pin it so Gradle's
  # toolchain machinery resolves to the JDK we provide instead of trying
  # to auto-download one.
  env.JAVA_VERSION = lib.versions.major jdk21.version;
  doCheck = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 build/libs/jspecify-${finalAttrs.version}.jar \
      $out/share/java/jspecify-${finalAttrs.version}.jar

    runHook postInstall
  '';

  gradleBuildTask = "assemble";

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  passthru.updateScript = writeShellScript "update-jspecify" ''
    ${lib.getExe nix-update} jspecify
    $(nix-build -A jspecify.mitmCache.updateScript)
  '';

  meta = {
    inherit (jre_minimal.meta) platforms;
    description = "Standard Annotations for Java Static Analysis";
    homepage = "https://jspecify.dev";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ msgilligan ];
  };
})
