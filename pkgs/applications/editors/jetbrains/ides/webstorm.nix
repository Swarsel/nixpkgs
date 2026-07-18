{
  lib,
  stdenv,
  fetchurl,
  fsnotifier,
  libdbm,
  mkJetBrainsProduct,
  musl,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    aarch64-darwin = {
      hash = "sha256-ZYen6Ew0GYbBAmuGCDACPBsygxZ6sT787o6gqF9DJzw=";
      url = "https://download.jetbrains.com/webstorm/WebStorm-2026.1.4-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-f9KenMq1gtldzpBraSBwOb/186WQwh1ps5Ypj5JoOU0=";
      url = "https://download.jetbrains.com/webstorm/WebStorm-2026.1.4-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-BPuMTwZ3Xkk4SBRCdgZ8vCoEYjhTa3d8CFOqrGlcGg0=";
      url = "https://download.jetbrains.com/webstorm/WebStorm-2026.1.4.tar.gz";
    };
  };
  # update-script-end: urls
in
mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "webstorm";
  # update-script-start: version
  version = "2026.1.4";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    musl
  ];

  buildNumber = "261.26222.58";
  product = "WebStorm";
  wmClass = "jetbrains-webstorm";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Web IDE from JetBrains";
    longDescription = "WebStorm provides an editor for HTML, JavaScript (incl. Node.js), and CSS with on-the-fly code analysis, error prevention and automated refactorings for JavaScript code.";
    homepage = "https://www.jetbrains.com/webstorm/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [
      abaldeau
      tymscar
    ];
  };
}
