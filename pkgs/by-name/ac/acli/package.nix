{
  lib,
  fetchurl,
  buildFHSEnv,
  callPackage,
  stdenvNoCC,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  src =
    fetchurl
      sources.sources.${stdenvNoCC.hostPlatform.system}
        or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
  version = sources.version;

  meta = {
    description = "Atlassian Command Line Interface";
    homepage = "https://developer.atlassian.com/cloud/acli/guides/introduction";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.attrNames sources.sources;
    mainProgram = "acli";
  };

  updateScript = ./update.py;

  unwrapped = callPackage ./unwrapped.nix {
    inherit
      src
      version
      meta
      updateScript
      ;
  };
  wrapped = buildFHSEnv {
    inherit version;
    inherit meta;
    pname = "acli";
    runScript = "acli";

    targetPkgs =
      p: with p; [
        unwrapped

        cacert
        openssl

        # For rovodev
        zlib
        libffi
        sqlite
      ];

    passthru = {
      inherit unwrapped updateScript;
    };
  };
in
if stdenvNoCC.hostPlatform.isLinux then wrapped else unwrapped.override { pname = "acli"; }
