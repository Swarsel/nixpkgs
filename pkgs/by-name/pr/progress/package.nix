{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  pkg-config,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "progress";
  version = "0.17";

  src = fetchFromGitHub {
    owner = "Xfennec";
    repo = "progress";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-riewkageSZIlwDNMjYep9Pb2q1GJ+WMXazokJGbb4bE=";
  };

  nativeBuildInputs = [
    pkg-config
    which
  ];

  buildInputs = [ ncurses ];
  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Tool that shows the progress of coreutils programs";
    homepage = "https://github.com/Xfennec/progress";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "progress";
  };
})
