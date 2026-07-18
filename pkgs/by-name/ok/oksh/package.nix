{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  ncurses,
}:

stdenv.mkDerivation rec {
  pname = "oksh";
  version = "7.9";

  src = fetchFromGitHub {
    owner = "ibara";
    repo = "oksh";
    rev = "oksh-${version}";
    hash = "sha256-7YgKRlu/5FGZivANa2z6RQp7qKFX44xFuqNV6nwbAXI=";
  };

  postPatch = lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform) ''
    substituteInPlace configure --replace "./conftest" "echo"
  '';

  strictDeps = true;
  buildInputs = [ ncurses ];
  configureFlags = [ "--no-strip" ];

  passthru = {
    shellPath = "/bin/oksh";
  };

  meta = {
    description = "Portable OpenBSD ksh, based on the Public Domain Korn Shell (pdksh)";
    homepage = "https://github.com/ibara/oksh";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
    mainProgram = "oksh";
  };
}
