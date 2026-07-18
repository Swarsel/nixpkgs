{
  stdenv,
  fetchurl,
  graalvmPackages,
}:

graalvmPackages.buildGraalvmProduct {
  version = (import ./hashes.nix).version;
  src = fetchurl (import ./hashes.nix).hashes.${stdenv.system};
  doInstallCheck = true;

  installCheckPhase = ''
    echo "Testing GraalJS"
    echo '1 + 1' | $out/bin/js
  '';

  product = "graaljs";
}
