{
  lib,
  fetchurl,
  haskellPackages,
  stdenvNoCC,
  writers,
}:

stdenvNoCC.mkDerivation rec {
  inherit (haskellPackages.hledger-lib) version;
  pname = "hledger-check-fancyassertions";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/simonmichael/hledger/hledger-lib-${version}/bin/hledger-check-fancyassertions.hs";
    hash = "sha256-ISA7ED0HgyWOxfaufaFpNb1dHfE+1+Xh4SRCZ64yM6E=";
    name = "hledger-check-fancyassertion-${version}.hs";
  };

  installPhase = ''
    runHook preInstall
    install -D $executable $out/bin/${pname}
    runHook postInstall
  '';

  dontBuild = true;
  dontUnpack = true;

  executable = writers.writeHaskell "hledger-check-fancyassertions" {
    inherit (haskellPackages) ghc;

    libraries = with haskellPackages; [
      hledger-lib
      base
      base-compat
      base-compat-batteries
      filepath
      megaparsec
      microlens
      optparse-applicative
      string-qq
      text
      time
      transformers
    ];
  } src;

  meta = {
    description = "Complex account balance assertions for hledger journals";
    homepage = "https://hledger.org/";
    changelog = "https://github.com/simonmichael/hledger/blob/${version}/hledger/CHANGES.md";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.DamienCassou ];
    platforms = lib.platforms.all; # GHC can cross-compile
    mainProgram = "hledger-check-fancyassertions";
  };
}
