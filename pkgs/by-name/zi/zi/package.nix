{
  lib,
  fetchFromGitHub,
  installShellFiles,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "zi";
  version = "unstable-2022-04-09";

  src = fetchFromGitHub {
    owner = "z-shell";
    repo = "zi";
    rev = "4ca4d3276ca816c3d37a31e47d754f9a732c40b9";
    sha256 = "sha256-KcDFT0is5Ef/zRo6zVfxYfBMOb5oVaVFT4EsUrfiMko=";
  };

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out
    cp -r lib zi.zsh $out
    installManPage docs/man/zi.1
    installShellCompletion --zsh lib/_zi
  '';

  dontBuild = true;

  meta = {
    description = "Swiss Army Knife for Zsh - Unix Shell";
    homepage = "https://github.com/z-shell/zi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sei40kr ];
  };
}
