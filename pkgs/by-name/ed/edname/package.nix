{
  lib,
  stdenv,
  coreutils,
  fetchFromGitea,
  findutils,
  gnused,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {

  pname = "edname";
  version = "1.0.2";

  src = fetchFromGitea {
    owner = "TudbuT";
    repo = "edname";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8aT/xwdx/ORyCFfOu4LZuxUiErZ9ZiCdhJ/WKAiQwe0=";
    domain = "git.tudbut.de";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp edname.sh "$out/bin/edname"
    wrapProgram "$out/bin/edname" \
      --prefix PATH : "${
        lib.makeBinPath [
          coreutils
          findutils
          gnused
        ]
      }"
  '';

  meta = {
    description = "Mass renamer using $EDITOR";
    homepage = "https://git.tudbut.de/TudbuT/edname";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.tudbut ];
    mainProgram = "edname";
  };
})
