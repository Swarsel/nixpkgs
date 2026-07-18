{
  lib,
  stdenv,
  fetchurl,
  e2fsprogs,
  installShellFiles,
}:

let
  manpage = fetchurl {
    sha256 = "0y132xmjl02vw41k794psa4nmjpdyky9f6sf0h4f7rvf83z3zy4k";
    url = "https://manpages.ubuntu.com/manpages.gz/xenial/man8/zerofree.8.gz";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zerofree";
  version = "1.1.1";

  src = fetchurl {
    url = "https://frippery.org/uml/zerofree-${finalAttrs.version}.tgz";
    sha256 = "0rrqfa5z103ws89vi8kfvbks1cfs74ix6n1wb6vs582vnmhwhswm";
  };

  buildInputs = [
    e2fsprogs
    installShellFiles
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/zerofree
    cp zerofree $out/bin
    cp COPYING $out/share/zerofree/COPYING
    installManPage ${manpage}
  '';

  meta = {
    description = "Zero free blocks from ext2, ext3 and ext4 file-systems";
    homepage = "https://frippery.org/uml/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.theuni ];
    platforms = lib.platforms.linux;
    mainProgram = "zerofree";
  };
})
