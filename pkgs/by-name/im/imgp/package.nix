{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imgp";
  version = "2.9";

  src = fetchFromGitHub {
    owner = "jarun";
    repo = "imgp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yQ2BzOBn6Bl9ieZkREKsj1zLnoPcf0hZhZ90Za5kiKA=";
  };

  checkPhase = ''
    $out/bin/imgp --help
  '';

  postInstall = ''
    install -Dm555 auto-completion/bash/imgp-completion.bash $out/share/bash-completion/completions/imgp.bash
    install -Dm555 auto-completion/fish/imgp.fish -t $out/share/fish/vendor_completions.d
    install -Dm555 auto-completion/zsh/_imgp -t $out/share/zsh/site-functions
  '';

  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.pillow ];

  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  pyproject = true;

  meta = {
    description = "High-performance CLI batch image resizer & rotator";
    homepage = "https://github.com/jarun/imgp";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "imgp";
  };
})
