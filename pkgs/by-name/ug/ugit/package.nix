{
  lib,
  fetchFromGitHub,
  bash,
  curl,
  fzf,
  git,
  ncurses,
  nix-update-script,
  stdenvNoCC,
  testers,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ugit";
  version = "5.9";

  src = fetchFromGitHub {
    owner = "Bhupesh-V";
    repo = "ugit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MufnBUVjEpEpZ/zyzo2e/hj+XJlikSSaXFwscCdaU48=";
  };

  postPatch = ''
    substituteInPlace ugit \
      --replace-fail "fzf " "${lib.getExe fzf} " \
      --replace-fail "curl" "${lib.getExe curl}" \
      --replace-fail "tput " "${ncurses}/bin/tput "
  '';

  strictDeps = true;

  buildInputs = [
    fzf
    curl
    bash
    ncurses
  ];

  propagatedBuildInputs = [ git ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ugit $out/bin/ugit
    ln -s $out/bin/ugit $out/bin/git-undo
    install -Dm644 ugit.plugin.zsh $out/share/zsh/ugit/ugit.zsh

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ ncurses ];

  installCheckPhase = ''
    runHook preInstallCheck

    PATH=$PATH:$out/bin ugit --help

    runHook postInstallCheck
  '';

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool that helps undoing the last git command with grace";
    homepage = "https://github.com/Bhupesh-V/ugit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ d-brasher ];
    platforms = lib.platforms.unix;
    mainProgram = "ugit";
    downloadPage = "https://github.com/Bhupesh-V/ugit/releases";
  };
})
