{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zplug";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "zplug";
    repo = "zplug";
    rev = finalAttrs.version;
    sha256 = "0hci1pbs3k5icwfyfw5pzcgigbh9vavprxxvakg1xm19n8zb61b3";
  };

  strictDeps = true;

  installPhase = ''
    mkdir -p $out/share/zplug
    cp -r $src/{autoload,base,bin,init.zsh,misc} $out/share/zplug/
    mkdir -p $out/share/man
    cp -r $src/doc/man/* $out/share/man/
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatch = true;

  meta = {
    description = "Next-generation plugin manager for zsh";
    homepage = "https://github.com/zplug/zplug";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.s1341 ];
    platforms = lib.platforms.all;
    mainProgram = "zplug-env";
  };
})
