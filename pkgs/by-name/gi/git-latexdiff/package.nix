{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoc,
  coreutils,
  gnused,
  installShellFiles,
  makeBinaryWrapper,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-latexdiff";
  version = "1.7.1";

  src = fetchFromGitLab {
    owner = "git-latexdiff";
    repo = "git-latexdiff";
    tag = finalAttrs.version;
    hash = "sha256-ocEDds1vAnaj84YiAez150OZV82w3NlsgXoxNbUGW/Q=";
  };

  postPatch = ''
    substituteInPlace git-latexdiff \
      --replace-fail "@GIT_LATEXDIFF_VERSION@" "v${finalAttrs.version}"
    patchShebangs git-latexdiff
  '';

  nativeBuildInputs = [
    installShellFiles
    asciidoc
    makeBinaryWrapper
  ];

  installPhase = ''
    installBin git-latexdiff
    wrapProgram ''${!outputBin}/bin/git-latexdiff \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gnused
        ]
      }
    make git-latexdiff.1
    installManPage git-latexdiff.1
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontBuild = true;

  meta = {
    description = "View diff on LaTeX source files on the generated PDF files";
    homepage = "https://gitlab.com/git-latexdiff/git-latexdiff";
    license = lib.licenses.bsd3; # https://gitlab.com/git-latexdiff/git-latexdiff/issues/9
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.unix;
    mainProgram = "git-latexdiff";
  };
})
