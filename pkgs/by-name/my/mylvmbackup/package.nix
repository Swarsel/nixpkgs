{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mylvmbackup";
  version = "0.16";

  src = fetchurl {
    url = "https://www.lenzg.net/mylvmbackup/mylvmbackup-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-vb7M3EPIrxIz6jUwm241fzaEz2czqdCObrFgSOSgJRU=";
  };

  postPatch = ''
    patchShebangs mylvmbackup
    substituteInPlace Makefile \
      --replace "prefix = /usr/local" "prefix = ${placeholder "out"}" \
      --replace "sysconfdir = /etc" "sysconfdir = ${placeholder "out"}/etc" \
      --replace "/usr/bin/install" "install"
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perlPackages.perl ];

  postInstall = ''
    wrapProgram "$out/bin/mylvmbackup" \
      --prefix PERL5LIB : "${
        perlPackages.makePerlPath (
          with perlPackages;
          [
            ConfigIniFiles
            DBDmysql
            DBI
            TimeDate
            FileCopyRecursive
          ]
        )
      }"
  '';

  dontConfigure = true;

  meta = {
    description = "Tool for quickly creating full physical backups of a MySQL server's data files";
    homepage = "https://www.lenzg.net/mylvmbackup/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ryantm ];
    platforms = with lib.platforms; linux;
    mainProgram = "mylvmbackup";
  };
})
