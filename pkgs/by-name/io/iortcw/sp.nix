{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  curl,
  freetype,
  libjpeg,
  libogg,
  makeWrapper,
  openal,
  opusfile,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iortcw-sp";
  version = "1.51c";

  src = fetchFromGitHub {
    owner = "iortcw";
    repo = "iortcw";
    tag = finalAttrs.version;
    hash = "sha256-3F8JAEuPydufXqeOGwYCX0M8pEVRyFZAu2TUFxZ+vDw=";
  };

  # Constexpr is a reserved keyword since C++11 that can't be overwritten. Replacing constexpr with
  # const_expr is necessary in this case for the build to function.
  postPatch = ''
    substituteInPlace code/tools/lcc/src/{c.h,init.c,simp.c,stmt.c} \
      --replace-fail 'constexpr' 'const_expr'
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    opusfile
    libogg
    SDL2
    freetype
    libjpeg
    openal
    curl
  ];

  makeFlags = [
    "USE_INTERNAL_LIBS=0"
    "COPYDIR=${placeholder "out"}/opt/iortcw"
    "USE_OPENAL_DLOPEN=0"
    "USE_CURL_DLOPEN=0"
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-I${lib.getInclude SDL2}/include/SDL2"
      "-I${opusfile.dev}/include/opus"
    ];

    NIX_CFLAGS_LINK = toString [
      "-lSDL2"
    ];
  };

  postInstall = ''
    for i in `find $out/opt/iortcw -maxdepth 1 -type f -executable`; do
      makeWrapper $i $out/bin/`basename $i` --chdir "$out/opt/iortcw"
    done
  '';

  enableParallelBuilding = true;
  installTargets = [ "copyfiles" ];
  sourceRoot = "${finalAttrs.src.name}/SP";

  meta = {
    description = "Single player version of game engine for Return to Castle Wolfenstein";
    homepage = finalAttrs.src.meta.homepage;
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ rjpcasalino ];
    platforms = lib.platforms.linux;
  };
})
