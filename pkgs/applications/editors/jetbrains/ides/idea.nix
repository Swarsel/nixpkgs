{
  lib,
  stdenv,
  fetchurl,
  fsnotifier,
  libdbm,
  lldb,
  maven,
  mkJetBrainsProduct,
  musl,
  zlib,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    aarch64-darwin = {
      hash = "sha256-XIBK/+Lxaz9dX+Lxl7HXsl+Z3Z7GBzSuDxNssb/4A2s=";
      url = "https://download.jetbrains.com/idea/ideaIU-2026.1.4-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-MDZFuLrUxcCIc0Zhi4QhgKPeU7Pgs9oJ/FxQH1n3gBM=";
      url = "https://download.jetbrains.com/idea/ideaIU-2026.1.4-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-MQTYXZUH/4ggZeP465UGQCtKgSkJLSaCZiu26cTwY/w=";
      url = "https://download.jetbrains.com/idea/ideaIU-2026.1.4.tar.gz";
    };
  };
  # update-script-end: urls
in
mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "idea";
  # update-script-start: version
  version = "2026.1.4";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    lldb
    musl
  ];

  buildNumber = "261.26222.65";
  extraLdPath = [ zlib ];

  extraWrapperArgs = [
    ''--set M2_HOME "${maven}/maven"''
    ''--set M2 "${maven}/maven/bin"''
  ];

  product = "IntelliJ IDEA";
  productShort = "IDEA";
  wmClass = "jetbrains-idea";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Java, Kotlin, Groovy and Scala IDE from JetBrains";

    longDescription = ''
      IDE for Java SE, Groovy & Scala development Powerful environment for building Google Android apps Integration with JUnit, TestNG, popular SCMs, Ant & Maven.
      Also known as IntelliJ.
    '';

    homepage = "https://www.jetbrains.com/idea/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [
      gytis-ivaskevicius
      tymscar
    ];
  };
}
