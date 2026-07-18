{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "proj-datumgrid";
  version = "world-1.0";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "proj-datumgrid";
    rev = finalAttrs.version;
    sha256 = "132wp77fszx33wann0fjkmi1isxvsb0v9iw0gd9sxapa9h6hf3am";
  };

  buildPhase = ''
    $CC nad2bin.c -o nad2bin
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp nad2bin $out/bin/
  '';

  sourceRoot = "${finalAttrs.src.name}/scripts";

  meta = {
    description = "Repository for proj datum grids";
    homepage = "https://proj4.org";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "nad2bin";
  };
})
