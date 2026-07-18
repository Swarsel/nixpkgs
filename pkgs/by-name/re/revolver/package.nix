{
  lib,
  fetchFromGitHub,
  installShellFiles,
  ncurses,
  runCommand,
  stdenvNoCC,
  testers,
  unstableGitUpdater,
  zsh,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "revolver";
  version = "0.2.4-unstable-2020-09-30";

  src = fetchFromGitHub {
    owner = "molovo";
    repo = "revolver";
    rev = "6424e6cb14da38dc5d7760573eb6ecb2438e9661";
    hash = "sha256-2onqjtPIsgiEJj00oP5xXGkPZGQpGPVwcBOhmicqKcs=";
  };

  patches = [ ./no-external-call.patch ];

  postPatch = ''
    substituteInPlace revolver \
      --replace-fail "tput cols" "${ncurses}/bin/tput cols"
  '';

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
    zsh
    ncurses
  ];

  installPhase = ''
    runHook preInstall

    install -D revolver $out/bin/revolver

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd revolver --zsh revolver.zsh-completion
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ zsh ];

  installCheckPhase = ''
    runHook preInstallCheck

    PATH=$PATH:$out/bin revolver --help

    runHook postInstallCheck
  '';

  passthru = {
    tests = {
      version = testers.testVersion {
        # Wrong '0.2.0' version in the code
        version = "0.2.0";
        package = finalAttrs.finalPackage;
      };

      demo = runCommand "revolver-demo" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
        export HOME="$TEMPDIR"

        # Drop stdout, redirect stderr to stdout and check if it's not empty
        exec 9>&1
        echo "Running revolver demo..."
        if [[ $(revolver demo 2>&1 1>/dev/null | tee >(cat - >&9)) ]]; then
          exit 1
        fi
        echo "Demo done!"

        mkdir $out
      '';
    };

    updateScript = unstableGitUpdater {
      tagPrefix = "v";
    };
  };

  meta = {
    inherit (zsh.meta) platforms;
    description = "Progress spinner for ZSH scripts";
    homepage = "https://github.com/molovo/revolver";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ d-brasher ];
    mainProgram = "revolver";
    downloadPage = "https://github.com/molovo/revolver/releases";
  };
})
