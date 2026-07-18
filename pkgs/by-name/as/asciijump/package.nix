{
  lib,
  stdenv,
  fetchFromGitLab,
  ctags,
  slang,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "asciijump";
  version = "1.0.2_beta-12";

  src = fetchFromGitLab {
    owner = "games-team";
    repo = "asciijump";
    tag = "debian/${finalAttrs.version}";
    hash = "sha256-fD/5tWg/GzSfVYvUWsz1FHXhLx9ud0JRMkM9NhVePdA=";
    domain = "salsa.debian.org";
  };

  strictDeps = true;
  nativeBuildInputs = [ ctags ];
  buildInputs = [ slang ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-fsigned-char"
  ];

  postInstall = ''
    rm -rf $out/var
  '';

  enableParallelBuilding = true;

  patchPhase = ''
    for file in $(cat debian/patches/series); do
      echo "$file:"
      patch -p1 < debian/patches/$file
    done
  '';

  meta = {
    description = "Small and funny ASCII-art game about ski jumping";
    homepage = "https://salsa.debian.org/games-team/asciijump";
    changelog = "https://salsa.debian.org/games-team/asciijump/-/blob/${finalAttrs.src.tag}/debian/changelog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    mainProgram = "asciijump";
  };
})
