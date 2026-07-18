{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "mutest";
  version = "0-unstable-2023-02-24";

  src = fetchFromGitHub {
    owner = "ebassi";
    repo = "mutest";
    rev = "18a20071773f7c4b75e82a931ef9b916b273b3e5";
    sha256 = "z0kASte0/I48Fgxhblu24MjGHidWomhfFOhfStGtPn4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
  ];

  doCheck = true;

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "BDD testing framework for C, inspired by Mocha";
    homepage = "https://github.com/ebassi/mutest";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.all;
  };
}
