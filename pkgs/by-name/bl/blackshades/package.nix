{
  lib,
  stdenv,
  fetchFromSourcehut,
  glfw,
  libGL,
  libGLU,
  libsndfile,
  openal,
  runCommand,
  zig_0_14,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blackshades";
  version = "2.5.2-unstable-2025-03-12";

  src = fetchFromSourcehut {
    owner = "~cnx";
    repo = "blackshades";
    rev = "a2fbe0e08bedbbbb1089dbb8f3e3cb4d76917bd0";
    hash = "sha256-W6ltmWCw7jfiTiNlh60YVF7mz//8s+bgu4F9gy5cDgw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig_0_14 ];

  buildInputs = [
    glfw
    libGLU
    libGL
    libsndfile
    openal
  ];

  postConfigure = ''
    ln -s ${
      zig_0_14.fetchDeps {
        inherit (finalAttrs)
          src
          pname
          version
          ;

        hash = "sha256-wBIfLeaKtTow2Z7gjEgIFmqcTGWgpRWI+k0t294BslM=";
      }
    } $ZIG_GLOBAL_CACHE_DIR/p
  '';

  meta = {
    description = "Psychic bodyguard FPS";
    homepage = "https://sr.ht/~cnx/blackshades";
    changelog = "https://git.sr.ht/~cnx/blackshades/refs/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ McSinyx ];
    platforms = lib.platforms.linux;
    mainProgram = "blackshades";
  };
})
