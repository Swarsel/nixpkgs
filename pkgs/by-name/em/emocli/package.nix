{
  lib,
  fetchFromGitLab,
  buildNimPackage,
  unicode-emoji,
}:

buildNimPackage (finalAttrs: {
  pname = "emocli";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "AsbjornOlling";
    repo = "emocli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yJu+8P446gzRFOi9/+TcN8AKL0jKHUxhOvi/HXNWL1A=";
  };

  env.EMOCLI_DATAFILE = "${unicode-emoji}/share/unicode/emoji/emoji-test.txt";

  nimFlags = [
    "--maxLoopIterationsVM:1000000000"
  ];

  meta = {
    description = "Emoji picker for your command line";
    homepage = "https://gitlab.com/AsbjornOlling/emocli";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ asbjornolling ];
    mainProgram = "emocli";
  };
})
