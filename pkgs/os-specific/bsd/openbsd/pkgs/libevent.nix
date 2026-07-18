{ mkDerivation }:
mkDerivation {
  preInstall = ''
    mkdir -p $out/include
  '';

  path = "lib/libevent";
}
