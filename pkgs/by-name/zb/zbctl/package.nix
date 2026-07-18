{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zbctl";
  version = "8.4.19";

  src =
    if stdenvNoCC.hostPlatform.system == "x86_64-darwin" then
      fetchurl {
        url = "https://github.com/camunda/zeebe/releases/download/${finalAttrs.version}/zbctl.darwin";
        hash = "sha256-RuZX9TWuXBxxegLw0La0l9/6zh96V/2trJvZUoCvTKk=";
      }
    else if stdenvNoCC.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://github.com/camunda/zeebe/releases/download/${finalAttrs.version}/zbctl";
        hash = "sha256-NTJqmcOzpOzHjrtOHBU2J3u0f7sESBeZMbb8kx3zR38=";
      }
    else
      throw "Unsupported platform ${stdenvNoCC.hostPlatform.system}";

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/zbctl

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  meta = {
    description = "Command line interface to interact with Camunda 8 and Zeebe";

    longDescription = ''
      A command line interface for Camunda Platform 8 designed to create and read resources inside a Zeebe broker.
      It can be used for regular development and maintenance tasks such as:
      * Deploying processes
      * Creating process instances and job workers
      * Activating, completing, or failing jobs
      * Updating variables and retries
      * Viewing cluster status
    '';

    homepage = "https://docs.camunda.io/docs/apis-clients/cli-client/";
    changelog = "https://github.com/camunda/zeebe/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ thetallestjj ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "zbctl";
    downloadPage = "https://github.com/camunda/zeebe/releases";
  };
})
