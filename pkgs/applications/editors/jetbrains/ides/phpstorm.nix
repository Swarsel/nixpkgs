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
      hash = "sha256-XGcfEWHHeLugvkT/WlQDsVRN33F46b1PCNhINQitqSY=";
      url = "https://download.jetbrains.com/webide/PhpStorm-2026.1.4-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-T9q3/nxv/AA6y7CHWtOhUibR7bnKN8OZmfN3NWYTsIQ=";
      url = "https://download.jetbrains.com/webide/PhpStorm-2026.1.4-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-SF25D7dDn7b6AzcXEDLKwhpjTnCqYz1fEmvND5dl8Is=";
      url = "https://download.jetbrains.com/webide/PhpStorm-2026.1.4.tar.gz";
    };
  };
  # update-script-end: urls
in
mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "phpstorm";
  # update-script-start: version
  version = "2026.1.4";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    musl
  ];

  buildNumber = "261.26222.71";
  product = "PhpStorm";
  wmClass = "jetbrains-phpstorm";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "PHP IDE from JetBrains";
    longDescription = "PhpStorm provides an editor for PHP, HTML and JavaScript with on-the-fly code analysis, error prevention and automated refactorings for PHP and JavaScript code.";
    homepage = "https://www.jetbrains.com/phpstorm/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [ tymscar ];
  };
}
