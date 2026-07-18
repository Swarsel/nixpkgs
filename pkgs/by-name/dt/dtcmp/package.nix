{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  lwgrp,
  mpi,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtcmp";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "dtcmp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Dc+c8JCc5D23CtpwiWkHCqngywEZXw7cYsRiSYiQdWk=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ lwgrp ];
  propagatedBuildInputs = [ mpi ];
  configureFlags = [ "--with-lwgrp=${lib.getDev lwgrp}" ];

  meta = {
    description = "MPI datatype comparison library";
    homepage = "https://github.com/LLNL/dtcmp";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux;
  };
})
