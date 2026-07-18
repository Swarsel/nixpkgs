{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libbraiding";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "miguelmarco";
    repo = "libbraiding";
    rev = version;
    hash = "sha256-Vo4nwzChjrI4PeNB+adPwDeL3gb++DEc4isX4/iDHMc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  # no tests included for now (2018-08-05), but can't hurt to activate
  doCheck = true;

  meta = {
    description = "C++ library for computations on braid groups";

    longDescription = ''
      A library to compute several properties of braids, including centralizer and conjugacy check.
    '';

    homepage = "https://github.com/miguelmarco/libbraiding/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.all;
    teams = [ lib.teams.sage ];
  };
}
