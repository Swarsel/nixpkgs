{
  lib,
  stdenv,
  fetchurl,
  sendmailPath ? "/run/wrappers/bin/sendmail",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ts";
  version = "1.0.3";

  src = fetchurl {
    url = "https://viric.name/~viric/soft/ts/ts-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-+oMzEVQ9xTW2DLerg8ZKte4xEo26qqE93jQZhOVCtCg=";
  };

  installPhase = ''make install "PREFIX=$out"'';

  patchPhase = ''
    sed -i s,/usr/sbin/sendmail,${sendmailPath}, mail.c ts.1
  '';

  meta = {
    description = "Task spooler - batch queue";
    homepage = "http://vicerveza.homeunix.net/~viric/soft/ts";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "ts";
  };
})
