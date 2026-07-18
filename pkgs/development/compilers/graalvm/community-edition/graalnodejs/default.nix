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
    echo "Testing NodeJS"
    $out/bin/npx --help
  '';

  product = "graalnodejs";
}
