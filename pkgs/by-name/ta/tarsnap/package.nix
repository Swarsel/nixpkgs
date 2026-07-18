{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  e2fsprogs,
  installShellFiles,
  openssl,
  zlib,
}:

let
  zshCompletion = fetchurl {
    sha256 = "0pawqwichzpz29rva7mh8lpx4zznnrh2rqyzzj6h7z98l0dxpair";
    url = "https://gist.githubusercontent.com/thoughtpolice/daa9431044883d3896f6/raw/282360677007db9739e5bf229873d3b231eb303a/tarsnap.zsh";
  };
in
stdenv.mkDerivation rec {
  pname = "tarsnap";
  version = "1.0.41";

  src = fetchurl {
    url = "https://www.tarsnap.com/download/tarsnap-autoconf-${version}.tgz";
    hash = "sha256-vr2+Hm6RIzdVvrQu8LStvv2Vc0VSWPAJ+zMVVseZs9A=";
  };

  postPatch = ''
    substituteInPlace Makefile.in \
      --replace-fail "command -p mv" "mv"
    substituteInPlace configure \
      --replace-fail "command -p getconf PATH" "echo $PATH"
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    openssl
    zlib
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux e2fsprogs
  ++ lib.optional stdenv.hostPlatform.isDarwin bzip2;

  configureFlags = [
    "--with-bash-completion-dir=${placeholder "out"}/share/bash-completion/completions"
    # required for cross builds
    "--host=${stdenv.hostPlatform.system}"
  ];

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
  ];

  postInstall = ''
    # install third-party zsh completions (bash completions already available)
    installShellCompletion --cmd tarsnap \
      --zsh ${zshCompletion}
  '';

  meta = {
    description = "Online backups for the truly paranoid";
    homepage = "http://www.tarsnap.com/";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      thoughtpolice
      roconnor
    ];

    platforms = lib.platforms.unix;
    mainProgram = "tarsnap";
  };
}
