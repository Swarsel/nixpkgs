{
  lib,
  stdenv,
  fetchurl,
  fsnotifier,
  libdbm,
  mkJetBrainsProduct,
  musl,
  pyCharmCommonOverrides,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    aarch64-darwin = {
      hash = "sha256-qxSgp8r4S0KXjCCTIoAiEZFCn3uBE/0pWLLA6td0Fq0=";
      url = "https://download.jetbrains.com/python/pycharm-2026.1.4-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-71FbYpN0seJ5k/yZA7aoXgU4W/N1BhjtKl7W7Hic9UE=";
      url = "https://download.jetbrains.com/python/pycharm-2026.1.4-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-RIufgZhg/n+D1uEdcDyYRjTDfh8Jicyz4h0B1kTbVXs=";
      url = "https://download.jetbrains.com/python/pycharm-2026.1.4.tar.gz";
    };
  };
  # update-script-end: urls
in
(mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "pycharm";
  # update-script-start: version
  version = "2026.1.4";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    musl
  ];

  buildNumber = "261.26222.68";
  product = "PyCharm";
  wmClass = "jetbrains-pycharm";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Python IDE from JetBrains";

    longDescription = ''
      Python IDE with complete set of tools for productive development with Python programming language.
      In addition, the IDE provides high-class capabilities for professional Web development with Django framework and Google App Engine.
      It has powerful coding assistance, navigation, a lot of refactoring features, tight integration with various Version Control Systems, Unit testing and powerful Debugger.
    '';

    homepage = "https://www.jetbrains.com/pycharm/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [
      tymscar
    ];
  };
}).overrideAttrs
  pyCharmCommonOverrides
