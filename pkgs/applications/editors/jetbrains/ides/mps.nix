{
  lib,
  stdenv,
  fetchurl,
  fsnotifier,
  libdbm,
  mkJetBrainsProduct,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    aarch64-darwin = {
      hash = "sha256-3HnEHOhRRI9IYjBhc5FO7h5j4jBBDtZTVkmO/S1fBEQ=";
      url = "https://download.jetbrains.com/mps/2025.3/MPS-2025.3-macos-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-xAI+UrTheCTWHSdoI4YZvhTlrlc121M+OVFkfzd7a3k=";
      url = "https://download.jetbrains.com/mps/2025.3/MPS-2025.3.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-xAI+UrTheCTWHSdoI4YZvhTlrlc121M+OVFkfzd7a3k=";
      url = "https://download.jetbrains.com/mps/2025.3/MPS-2025.3.tar.gz";
    };
  };
  # update-script-end: urls
in
mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "mps";
  # update-script-start: version
  version = "2025.3";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));
  buildNumber = "253.28294.432";
  product = "MPS";
  wmClass = "jetbrains-MPS";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "IDE for building domain-specific languages from JetBrains";
    longDescription = "A metaprogramming system which uses projectional editing which allows users to overcome the limits of language parsers, and build DSL editors, such as ones with tables and diagrams.";
    homepage = "https://www.jetbrains.com/mps/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = [ ];
  };
}
