{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "zsh-zhooks";
  version = "0-unstable-2021-10-31";

  src = fetchFromGitHub {
    owner = "agkozak";
    repo = "zhooks";
    rev = "e6616b4a2786b45a56a2f591b79439836e678d22";
    hash = "sha256-zahXMPeJ8kb/UZd85RBcMbomB7HjfEKzQKjF2NnumhQ=";
  };

  installPhase = ''
    runHook preInstall
    install -m755 -D zhooks.plugin.zsh --target-directory $out/share/zsh/zhooks
    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Tool for displaying the code for all Zsh hook functions";

    longDescription = ''
      This Zsh plugin is a tool for displaying the code for all Zsh hook functions (such as precmd), as well as the contents of
      hook arrays (such as precmd_functions).
    '';

    homepage = "https://github.com/agkozak/zhooks";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.fidgetingbits ];
    platforms = lib.platforms.all;
  };
}
