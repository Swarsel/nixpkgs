{
  lib,
  stdenv,
  fetchurl,
  fsnotifier,
  libdbm,
  libgcc,
  mkJetBrainsProduct,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    aarch64-darwin = {
      hash = "sha256-AHY/lY0ARkW0VoSgy0t7LLNXA965PLooWBSWxBKBV5M=";
      url = "https://download.jetbrains.com/idea/gateway/JetBrainsGateway-2026.1.3-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-CSe04BBo4jS1cIhu4NfZqaSHMaNue2eFUPa+1gOxuoo=";
      url = "https://download.jetbrains.com/idea/gateway/JetBrainsGateway-2026.1.3-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-HizogKH6goX1NdcI/Fj4YsCRzDWfFvQGYSaMM9wVDCA=";
      url = "https://download.jetbrains.com/idea/gateway/JetBrainsGateway-2026.1.3.tar.gz";
    };
  };
  # update-script-end: urls
in
mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "gateway";
  # update-script-start: version
  version = "2026.1.3";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs = [
    libgcc
  ];

  buildNumber = "261.25134.98";
  product = "JetBrains Gateway";
  productShort = "Gateway";
  wmClass = "jetbrains-gateway";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Remote development for JetBrains products";
    longDescription = "JetBrains Gateway is a lightweight launcher that connects a remote server with your local machine and opens your project in JetBrains Client.";
    homepage = "https://www.jetbrains.com/remote-development/gateway/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = [ ];
  };
}
