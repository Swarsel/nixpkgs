{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  coreutils,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yallback";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "abathur";
    repo = "yallback";
    rev = "v${finalAttrs.version}";
    hash = "sha256-t+fdnDJMFiFqN23dSY3TnsZsIDcravtwdNKJ5MiZosE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    coreutils
    bashInteractive
  ];

  installPhase = ''
    install -Dv yallback $out/bin/yallback
    wrapProgram $out/bin/yallback --prefix PATH : ${lib.makeBinPath [ coreutils ]}
  '';

  meta = {
    description = "Callbacks for YARA rule matches";
    homepage = "https://github.com/abathur/yallback";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ abathur ];
    platforms = lib.platforms.all;
    mainProgram = "yallback";
  };
})
