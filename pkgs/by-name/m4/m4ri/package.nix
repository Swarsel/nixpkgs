{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "m4ri";
  version = "20260122";

  src = fetchFromGitHub {
    owner = "malb";
    repo = "m4ri";
    rev = finalAttrs.version;
    hash = "sha256-/M/DVl2tRXIz5l3LFwY8Bvxnzjeoluy+zVgBVpPSdZM=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  doCheck = true;

  meta = {
    description = "Library to do fast arithmetic with dense matrices over F_2";
    homepage = "https://malb.bitbucket.io/m4ri/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.sage ];
  };
})
