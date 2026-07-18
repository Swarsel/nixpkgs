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
      hash = "sha256-Kyt3fYPXzwTVxPFVKd+atiHWb/i7gjGahz1MJ4iXxy8=";
      url = "https://download.jetbrains.com/datagrip/datagrip-2026.1.3-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-G+tinD/+qM5HVR4u2E0cNXtdVsbwgK8/PdZ3ic6hf4M=";
      url = "https://download.jetbrains.com/datagrip/datagrip-2026.1.3-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-XxwvXiaWAfK318BjbzKPLVDeMBlOr5BFuD2bqU8+12o=";
      url = "https://download.jetbrains.com/datagrip/datagrip-2026.1.3.tar.gz";
    };
  };
  # update-script-end: urls
in
mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "datagrip";
  # update-script-start: version
  version = "2026.1.3";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));
  buildNumber = "261.24374.56";
  product = "DataGrip";
  wmClass = "jetbrains-datagrip";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Database IDE from JetBrains";

    longDescription = ''
      DataGrip is an IDE from JetBrains built for database admins.
      It allows you to quickly migrate and refactor relational databases, construct efficient, statically checked SQL queries and much more.
    '';

    homepage = "https://www.jetbrains.com/datagrip/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = [ ];
  };
}
