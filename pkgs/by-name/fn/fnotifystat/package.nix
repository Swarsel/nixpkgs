{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fnotifystat";
  version = "0.03.00";

  src = fetchFromGitHub {
    owner = "ColinIanKing";
    repo = "fnotifystat";
    rev = "V${finalAttrs.version}";
    hash = "sha256-UGww0/m+JMftQyAguc8UpPrtIphjCq9TINabFaAKN0A=";
  };

  installFlags = [
    "BINDIR=${placeholder "out"}/bin"
    "MANDIR=${placeholder "out"}/share/man/man8"
    "BASHDIR=${placeholder "out"}/share/bash-completion/completions"
  ];

  meta = {
    description = "File activity monitoring tool";
    homepage = "https://github.com/ColinIanKing/fnotifystat";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ womfoo ];
    platforms = lib.platforms.linux;
    mainProgram = "fnotifystat";
  };
})
