{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ncurses,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "lv";
  version = "4.51-unstable-2020-08-03";

  src = fetchFromGitHub {
    owner = "ttdoda";
    repo = "lv";
    rev = "1fb214d4136334a1f6cd932b99f85c74609e1f23";
    hash = "sha256-mUFiWzTTM6nAKQgXA0sYIUm1MwN7HBHD8LWBgzu3ZUk=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ ncurses ];
  makeFlags = [ "prefix=${placeholder "out"}" ];
  # Upstream needs quite a bit of porting to c23:
  #   https://github.com/ttdoda/lv/issues/3
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  preInstall = ''
    mkdir -p $out/bin
  '';

  configurePhase = ''
    mkdir -p build
    cd build
    ../src/configure
  '';

  postAutoreconf = "cd ..";
  preAutoreconf = "cd src";

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
  };

  meta = {
    description = "Powerful multi-lingual file viewer / grep";
    homepage = "https://github.com/ttdoda/lv";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ kayhide ];
    platforms = with lib.platforms; linux ++ darwin;
  };
}
