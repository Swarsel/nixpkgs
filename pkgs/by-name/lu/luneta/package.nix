{
  lib,
  fetchFromGitHub,
  buildDubPackage,
  ncurses,
}:

buildDubPackage rec {
  pname = "luneta";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "fbeline";
    repo = "luneta";
    rev = "v${version}";
    hash = "sha256-pYE8hccXT87JIMh71PtXzVQBegTzU7bdpVEaV2VkaEk=";
  };

  # not sure why, but this alias does not resolve
  postPatch = ''
    substituteInPlace source/luneta/keyboard.d \
        --replace-fail "wint_t" "dchar"
  '';

  buildInputs = [ ncurses ];

  installPhase = ''
    runHook preInstall
    install -Dm755 luneta -t $out/bin
    runHook postInstall
  '';

  # ncurses dub package version is locked to 1.0.0 instead of using ~master
  dubLock = ./dub-lock.json;

  meta = {
    description = "Interactive filter and fuzzy finder for the command-line";
    homepage = "https://github.com/fbeline/luneta";
    changelog = "https://github.com/fbeline/luneta/releases/tag/${src.rev}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "luneta";
  };
}
