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
      hash = "sha256-4wEnwcPRtwp0wxePUMiLow6sMxirwndRMdmJL8LBh9k=";
      url = "https://download.jetbrains.com/ruby/RubyMine-2026.1.4-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-oSu19pkGVWt31vWBdAffSZsu4QzsUznVbUSwDy98nug=";
      url = "https://download.jetbrains.com/ruby/RubyMine-2026.1.4-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-0EhtU4XKWI9i7ij+m5uvxHSYnbQaYJy8Sa6S1OW4CFU=";
      url = "https://download.jetbrains.com/ruby/RubyMine-2026.1.4.tar.gz";
    };
  };
  # update-script-end: urls
in
mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "ruby-mine";
  # update-script-start: version
  version = "2026.1.4";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    musl
  ];

  buildNumber = "261.26222.67";
  product = "RubyMine";
  wmClass = "jetbrains-rubymine";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Ruby IDE from JetBrains";
    longDescription = "Ruby IDE from JetBrains";
    homepage = "https://www.jetbrains.com/ruby/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [ tymscar ];
  };
}
