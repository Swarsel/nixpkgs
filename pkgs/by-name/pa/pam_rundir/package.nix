{
  lib,
  stdenv,
  fetchurl,
  pam,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pam_rundir";
  version = "1.0.0";

  src = fetchurl {
    url = "https://jjacky.com/pam_rundir/pam_rundir-${finalAttrs.version}.tar.gz";
    hash = "sha256-x3m2me0jd3o726h7f2ftOV/pV/PJYTj67kX4eie8wCA=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail /usr/share/man /share/man
  '';

  buildInputs = [
    pam
  ];

  configureFlags = [
    "--securedir=/lib/security"
    "--with-parentdir=/run/user"
  ];

  installFlags = [
    "DESTDIR=$(out)"
  ];

  meta = {
    description = "Provide user runtime directory on Linux systems";
    homepage = "http://jjacky.com/pam_rundir";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ aanderse ];
    platforms = lib.platforms.unix;
  };
})
