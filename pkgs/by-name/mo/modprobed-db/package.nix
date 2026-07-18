{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  installShellFiles,
  kmod,
  libevdev,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "modprobed-db";
  version = "2.50";

  src = fetchFromGitHub {
    owner = "graysky2";
    repo = "modprobed-db";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JcotyXFrxE9DmrGS8cx/+BvHeQ8rLd+0h4jIYD2NZmY=";
  };

  postPatch = ''
    substituteInPlace ./common/modprobed-db.in \
      --replace "/usr/share" "$out/share"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    kmod
    libevdev
    bash
  ];

  postInstall = ''
    installShellCompletion --zsh common/zsh-completion
  '';

  installFlags = [
    "PREFIX=$(out)"
    "INITDIR_SYSTEMD=$(out)/lib/systemd/user"
  ];

  meta = {
    description = "Useful utility for users wishing to build a minimal kernel via a make localmodconfig";
    homepage = "https://github.com/graysky2/modprobed-db";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ NotAShelf ];
    platforms = lib.platforms.linux;
    mainProgram = "modprobed-db";
  };
})
