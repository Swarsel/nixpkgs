{
  lib,
  fetchurl,
  buildGraalvmNativeImage,
  nix-update-script,
  testers,
}:

buildGraalvmNativeImage (finalAttrs: {
  pname = "cljfmt";
  version = "0.16.4";

  src = fetchurl {
    url = "https://github.com/weavejester/cljfmt/releases/download/${finalAttrs.version}/cljfmt-${finalAttrs.version}-standalone.jar";
    hash = "sha256-6GTK/QH0z7Qox5JFGWu4hacGiLvBVmJQHvw0K2sMMAw=";
  };

  extraNativeImageBuildArgs = [
    "-H:+ReportExceptionStackTraces"
    "-H:Log=registerResource:"
    "--initialize-at-build-time"
    "--diagnostics-mode"
    "--report-unsupported-elements-at-runtime"
    "--no-fallback"
  ];

  passthru.tests.version = testers.testVersion {
    inherit (finalAttrs) version;
    command = "cljfmt --version";
    package = finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for formatting Clojure code";
    homepage = "https://github.com/weavejester/cljfmt";
    changelog = "https://github.com/weavejester/cljfmt/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.epl10;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ sg-qwt ];
    mainProgram = "cljfmt";
  };
})
