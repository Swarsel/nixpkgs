{
  lib,
  stdenv,
  fetchurl,
}:

{
  pkg,
  sha256,
  version,
  meta ? { },
}:

stdenv.mkDerivation {
  inherit version;
  inherit meta;
  pname = pkg;

  src = fetchurl {
    inherit sha256;
    url = "https://repo.hex.pm/tarballs/${pkg}-${version}.tar";
  };

  installPhase = ''
    runHook preInstall
    mkdir "$out"
    cp -Hrt "$out" .
    success=1
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  unpackCmd = ''
    tar -xf $curSrc contents.tar.gz CHECKSUM metadata.config
    mkdir contents
    tar -C contents -xzf contents.tar.gz
    mv metadata.config contents/hex_metadata.config

    # To make the extracted hex tarballs appear legitimate to mix, we need to
    # make sure they contain not just the contents of contents.tar.gz but also
    # a .hex file with some lock metadata.
    # We use an old version of .hex file per hex's mix_task_test.exs since it
    # is just plain-text instead of an encoded format.
    # See: https://github.com/hexpm/hex/blob/main/test/hex/mix_task_test.exs#L410
    echo -n "${pkg},${version},$(cat CHECKSUM | tr '[:upper:]' '[:lower:]'),hexpm" > contents/.hex
  '';
}
