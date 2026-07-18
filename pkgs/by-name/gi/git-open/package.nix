{
  lib,
  stdenv,
  fetchFromGitHub,
  gnugrep,
  installShellFiles,
  makeWrapper,
  pandoc,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-open";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "paulirish";
    repo = "git-open";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-bZOknoRMkPqm1pFFFbvrHrSi90ANLEE5fLcABYHov6Q=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    pandoc
  ];

  buildPhase = ''
    # marked-man is broken and severly outdated.
    # pandoc with some extra metadata is good enough and produces a by man readable file.
    cat <(echo echo '% git-open (1) Version ${finalAttrs.version} | Git manual') git-open.1.md > tmp
    mv tmp git-open.1.md
    pandoc --standalone --to man git-open.1.md -o git-open.1
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv git-open $out/bin
    installManPage git-open.1
    wrapProgram $out/bin/git-open \
      --prefix PATH : "${lib.makeBinPath [ gnugrep ]}" \
      --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}"
  '';

  meta = {
    description = "Open the GitHub page or website for a repository in your browser";
    homepage = "https://github.com/paulirish/git-open";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    platforms = lib.platforms.all;
    mainProgram = "git-open";
  };
})
