{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ncurses,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "slurm-nm";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "mattthias";
    repo = "slurm";
    rev = "upstream/${finalAttrs.version}";
    hash = "sha256-w77SIXFctMwwNw9cQm0HQaEaMs/5NXQjn1LpvkpCCB8=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [ ncurses ];

  meta = {
    description = "Generic network load monitor";
    homepage = "https://github.com/mattthias/slurm";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ mikaelfangel ];
    platforms = lib.platforms.unix;
    mainProgram = "slurm";
  };
})
