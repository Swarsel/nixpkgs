{
  lib,
  fetchFromGitHub,
  bats,
  stdenvNoCC,
}:

let
  version = "0.6.0";
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "bash-preexec";

  src = fetchFromGitHub {
    owner = "rcaloras";
    repo = "bash-preexec";
    tag = version;
    hash = "sha256-4DzbeIiUX7iXy2CeSvRC2X+XnjVk+/UiMbM/dLHx7zU=";
  };

  doCheck = true;
  nativeCheckInputs = [ bats ];

  checkPhase = ''
    runHook preCheck
    bats test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bash-preexec.sh $out/share/bash/bash-preexec.sh
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  patchPhase = ''
    runHook prePatch

    # Needed since the tests expect that HISTCONTROL is set.
    sed -i '/setup()/a HISTCONTROL=""' test/bash-preexec.bats

    # Skip tests failing with Bats 1.5.0.
    # See https://github.com/rcaloras/bash-preexec/issues/121
    sed -i '/^@test.*IFS/,/^}/d' test/bash-preexec.bats

    runHook postPatch
  '';

  meta = {
    description = "Preexec and precmd functions for Bash just like Zsh";
    homepage = "https://github.com/rcaloras/bash-preexec";
    changelog = "https://github.com/rcaloras/bash-preexec/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hawkw
      rycee
    ];

    platforms = lib.platforms.unix;
  };
}
