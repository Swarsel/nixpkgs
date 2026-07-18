{
  lib,
  stdenv,
  fetchFromGitHub,
  unixtools,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-extras";
  version = "7.5.0";

  src = fetchFromGitHub {
    owner = "tj";
    repo = "git-extras";
    tag = finalAttrs.version;
    sha256 = "sha256-BmRLwdaP6Ic8cCtqPFaExEeqeE51l8JzzDmIfxz8Nvs=";
  };

  postPatch = ''
    patchShebangs check_dependencies.sh
  '';

  nativeBuildInputs = [
    unixtools.column
    which
  ];

  postInstall = ''
    # bash completion is already handled by make install
    install -D etc/git-extras-completion.zsh $out/share/zsh/site-functions/_git_extras
  '';

  dontBuild = true;

  installFlags = [
    "PREFIX=${placeholder "out"}"
    "SYSCONFDIR=${placeholder "out"}/share"
  ];

  meta = {
    description = "GIT utilities -- repo summary, repl, changelog population, author commit percentages and more";
    homepage = "https://github.com/tj/git-extras";
    changelog = "https://github.com/tj/git-extras/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    platforms = lib.platforms.all;
  };
})
