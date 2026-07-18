{
  lib,
  stdenv,
  fetchFromGitLab,
  fixDarwinDylibNames,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libz";
  version = "1.2.8.2025.03.07";

  src = fetchFromGitLab {
    owner = "sortix";
    repo = "libz";
    tag = "libz-${finalAttrs.version}";
    hash = "sha256-tr9r0X+iHz3LZFgIxi3JMQUnSlyTRtAIhtjwI+DIhpc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  outputDoc = "dev"; # single tiny man3 page

  passthru.updateScript = gitUpdater {
    rev-prefix = "libz-";
  };

  meta = {
    description = "Clean fork of zlib";
    homepage = "https://sortix.org/libz/";
    license = [ lib.licenses.zlib ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
