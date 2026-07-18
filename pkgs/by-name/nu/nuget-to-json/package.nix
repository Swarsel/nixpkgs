{
  lib,
  cacert,
  coreutils,
  curl,
  gawk,
  gnugrep,
  jq,
  nix,
  replaceVarsWith,
  runtimeShell,
  xmlstarlet,
}:

replaceVarsWith {
  src = ./nuget-to-json.sh;
  dir = "bin";
  isExecutable = true;
  name = "nuget-to-json";

  replacements = {
    inherit runtimeShell cacert;

    binPath = lib.makeBinPath [
      nix
      coreutils
      jq
      xmlstarlet
      curl
      gnugrep
      gawk
    ];
  };

  meta = {
    description = "Convert a nuget packages directory to a lockfile for buildDotnetModule";
    mainProgram = "nuget-to-json";
  };
}
