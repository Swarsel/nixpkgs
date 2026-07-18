{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  perl,
  readline,
  rsh,
  slurm,
  ssh,
  slurmSupport ? false,
}:

stdenv.mkDerivation rec {
  pname = "pdsh";
  version = "2.36";

  src = fetchurl {
    url = "https://github.com/chaos/pdsh/releases/download/pdsh-${version}/pdsh-${version}.tar.gz";
    sha256 = "sha256-pmEJXOUd1fsF45jPXQ4dYxVxI5WEQfbTUSvPGn0lxRc=";
  };

  # Do not use git to derive a version.
  postPatch = ''
    sed -i 's/m4_esyscmd(\[git describe.*/[${version}])/' configure.ac
  '';

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    perl
    readline
    ssh
  ]
  ++ (lib.optional slurmSupport slurm);

  preConfigure = ''
    configureFlagsArray=(
      "--infodir=$out/share/info"
      "--mandir=$out/share/man"
      "--with-machines=/etc/pdsh/machines"
      ${if readline == null then "--without-readline" else "--with-readline"}
      ${if ssh == null then "--without-ssh" else "--with-ssh"}
      ${if rsh == false then "--without-rsh" else "--with-rsh"}
      ${if slurmSupport then "--with-slurm" else "--without-slurm"}
      "--with-dshgroups"
      "--with-xcpu"
      "--disable-debug"
      '--with-rcmd-rank-list=ssh,krb4,exec,xcpu,rsh'
    )
  '';

  meta = {
    description = "High-performance, parallel remote shell utility";

    longDescription = ''
      Pdsh is a high-performance, parallel remote shell utility. It has
      built-in, thread-safe clients for Berkeley and Kerberos V4 rsh and
      can call SSH externally (though with reduced performance). Pdsh
      uses a "sliding window" parallel algorithm to conserve socket
      resources on the initiating node and to allow progress to continue
      while timeouts occur on some connections.
    '';

    homepage = "https://github.com/chaos/pdsh";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
}
