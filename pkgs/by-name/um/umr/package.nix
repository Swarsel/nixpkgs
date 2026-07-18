{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  bash-completion,
  cmake,
  libdrm,
  libgbm,
  libpciaccess,
  llvmPackages,
  nanomsg,
  ncurses,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "umr";
  version = "1.0.10";

  src = fetchFromGitLab {
    owner = "tomstdenis";
    repo = "umr";
    rev = finalAttrs.version;
    hash = "sha256-i0pTcg1Y+G/nGZSbMtlg37z12gF4heitEl5L4gfVO9c=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libdrm
    libgbm
    libpciaccess
    llvmPackages.llvm
    nanomsg
    ncurses
    SDL2

    bash-completion # Tries to create bash-completions in /var/empty otherwise?
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Userspace debugging and diagnostic tool for AMD GPUs";
    homepage = "https://gitlab.freedesktop.org/tomstdenis/umr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Flakebi ];
    platforms = lib.platforms.linux;
  };
})
