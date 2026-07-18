{
  lib,
  fetchFromGitHub,
  coreutils,
  git,
  gnugrep,
  gnused,
  makeWrapper,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "git-fixup";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "keis";
    repo = "git-fixup";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Mue2xgYxJSEu0VoDmB7rnoSuzyT038xzETUO1fwptrs=";
  };

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    "PREFIX="
  ];

  postInstall = ''
    wrapProgram $out/bin/git-fixup \
      --prefix PATH : "${
        lib.makeBinPath [
          git
          coreutils
          gnused
          gnugrep
        ]
      }"
  '';

  dontBuild = true;

  installFlags = [
    "install"
    "install-fish"
    "install-zsh"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fighting the copy-paste element of your rebase workflow";
    homepage = "https://github.com/keis/git-fixup";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ michaeladler ];
    platforms = lib.platforms.all;
    mainProgram = "git-fixup";
  };
})
