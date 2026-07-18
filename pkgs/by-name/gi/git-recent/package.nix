{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  less,
  makeBinaryWrapper,
  util-linuxMinimal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-recent";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "paulirish";
    repo = "git-recent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b6AWLEXCOza+lIHlvyYs3M6yHGr2StYXzl7OsA9gv/k=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    install -D -m755 -t $out/bin git-recent

    wrapProgram $out/bin/git-recent \
      --prefix PATH : "${
        lib.makeBinPath [
          gitMinimal
          less
          util-linuxMinimal
        ]
      }"

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "See your latest local git branches, formatted real fancy";
    homepage = "https://github.com/paulirish/git-recent";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jlesquembre ];
    platforms = lib.platforms.all;
    mainProgram = "git-recent";
  };
})
