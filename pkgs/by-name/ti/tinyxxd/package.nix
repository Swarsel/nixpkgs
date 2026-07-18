{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  vim,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tinyxxd";
  version = "1.3.16";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = "tinyxxd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SaxjQFQ//xxRCIx4FMx1exGGOGEKN/evgABTquL92WM=";
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage tinyxxd.1

    # Allow using `tinyxxd` as `xxd`. This is similar to the Arch packaging.
    # https://gitlab.archlinux.org/archlinux/packaging/packages/tinyxxd/-/blob/main/PKGBUILD
    ln -s $out/bin/{tiny,}xxd
    ln -s $out/share/man/man1/{tiny,}xxd.1.gz
  '';

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Drop-in replacement and standalone version of the hex dump utility that comes with ViM";
    homepage = "https://github.com/xyproto/tinyxxd";

    license = [
      lib.licenses.mit # or
      lib.licenses.gpl2Only
    ];

    maintainers = with lib.maintainers; [
      emily
      philiptaron
    ];

    platforms = lib.platforms.unix;
    mainProgram = "tinyxxd";
    # If the two `xxd` providers are present, choose this one.
    priority = (vim.xxd.meta.priority or lib.meta.defaultPriority) - 1;
  };
})
