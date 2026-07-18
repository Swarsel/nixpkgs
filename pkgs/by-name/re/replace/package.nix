{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "replace";
  version = "2.24";

  src = fetchurl {
    url = "http://hpux.connect.org.uk/ftp/hpux/Users/replace-${finalAttrs.version}/replace-${finalAttrs.version}-src-11.31.tar.gz";
    sha256 = "18hkwhaz25s6209n5mpx9hmkyznlzygqj488p2l7nvp9zrlxb9sf";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [ ./malloc.patch ];

  makeFlags = [
    "TREE=\$(out)"
    "MANTREE=\$(TREE)/share/man"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  preBuild = ''
    sed -e "s@/bin/mv@$(type -P mv)@" -i replace.h
  '';

  preInstall = "mkdir -p \$out/share/man";
  postInstall = "mv \$out/bin/replace \$out/bin/replace-literal";

  meta = {
    description = "Tool to replace verbatim strings";
    homepage = "https://replace.richardlloyd.org.uk/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.unix;
    mainProgram = "replace-literal";
  };
})
