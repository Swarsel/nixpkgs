{
  lib,
  stdenv,
  fetchFromGitHub,
}:

# To make use of this derivation, use the `programs.zsh.enableSyntaxHighlighting` option

stdenv.mkDerivation (finalAttrs: {
  pname = "zsh-syntax-highlighting";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-syntax-highlighting";
    rev = finalAttrs.version;
    hash = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
  };

  strictDeps = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Fish shell like syntax highlighting for Zsh";
    homepage = "https://github.com/zsh-users/zsh-syntax-highlighting";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      gepbird
      loskutov
    ];

    platforms = lib.platforms.unix;
  };
})
