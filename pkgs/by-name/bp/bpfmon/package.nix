{
  lib,
  stdenv,
  fetchFromGitHub,
  libpcap,
  yascreen,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bpfmon";
  version = "2.53";

  src = fetchFromGitHub {
    owner = "bbonev";
    repo = "bpfmon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+W+3RLvgXXtUImzLkJr9mSWExvAUgjMp+lR9sg14VaY=";
  };

  buildInputs = [
    libpcap
    yascreen
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  meta = {
    description = "BPF based visual packet rate monitor";
    homepage = "https://github.com/bbonev/bpfmon";
    changelog = "https://github.com/bbonev/bpfmon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ arezvov ];
    platforms = lib.platforms.linux;
    mainProgram = "bpfmon";
  };
})
