{
  lib,
  stdenv,
  fetchurl,
  R,
  fsnotifier,
  libdbm,
  libgcc,
  mkJetBrainsProduct,
  runCommand,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    aarch64-darwin = {
      hash = "sha256-MGWufS0nlswdqhACNQWtlXJwfPiYw8wUx7olIxPS15k=";
      url = "https://download.jetbrains.com/python/dataspell-2026.1.2-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-SSmIPF0pDMolxeXL21UaHMbZdtYbChWVxTKZOsPhH+I=";
      url = "https://download.jetbrains.com/python/dataspell-2026.1.2-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-D5eONrO+5EL1cuskUU4cRYLgcbG7RCvlucnmw9t2COM=";
      url = "https://download.jetbrains.com/python/dataspell-2026.1.2.tar.gz";
    };
  };
  # update-script-end: urls
in
mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "dataspell";
  # update-script-start: version
  version = "2026.1.2";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  # NOTE: This `lib.optionals` is only here because the old Darwin builder ignored `buildInputs`.
  #       DataSpell may need these, even on Darwin!
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libgcc
    (runCommand "libR" { } ''
      mkdir -p $out/lib
      ln -s ${R}/lib/R/lib/libR.so $out/lib/libR.so
    '')
  ];

  buildNumber = "261.25134.18";
  product = "DataSpell";
  wmClass = "jetbrains-dataspell";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Data science IDE from JetBrains";

    longDescription = ''
      DataSpell is an IDE from JetBrains built for Data Scientists.
      Mainly it integrates Jupyter notebooks in the IntelliJ platform.
    '';

    homepage = "https://www.jetbrains.com/dataspell/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [ leona ];
  };
}
