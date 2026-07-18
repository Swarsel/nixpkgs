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
    echo "Testing GraalPy"
    $out/bin/graalpy -c 'print(1 + 1)'
    echo '1 + 1' | $out/bin/graalpy
  '';

  product = "graalpy";
}
