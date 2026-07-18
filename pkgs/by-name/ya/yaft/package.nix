{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yaft";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "uobikiemukot";
    repo = "yaft";
    rev = "v${finalAttrs.version}";
    sha256 = "0l1ig8wm545kpn4l7186rymny83jkahnjim290wsl7hsszfq1ckd";
  };

  outputs = [
    "out"
    "terminfo"
  ];

  buildInputs = [ ncurses ];

  postInstall = ''
    mkdir -p $out/nix-support $terminfo/share
    mv $out/share/terminfo $terminfo/share/
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
  '';

  installFlags = [
    "PREFIX=$(out)"
    "MANPREFIX=$(out)/share/man"
  ];

  meta = {
    description = "Yet another framebuffer terminal";
    homepage = "https://github.com/uobikiemukot/yaft";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = with lib.platforms; linux;
  };
})
