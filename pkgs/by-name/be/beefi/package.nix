{
  lib,
  stdenv,
  fetchFromGitHub,
  binutils-unwrapped,
  installShellFiles,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "beefi";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "jfeick";
    repo = "beefi";
    tag = finalAttrs.version;
    sha256 = "1180avalbw414q1gnfqdgc9zg3k9y0401kw9qvcn51qph81d04v5";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
    binutils-unwrapped
    systemd
  ];

  installPhase = ''
    install -Dm755 beefi $out/bin/beefi
    installManPage beefi.1
  '';

  patchPhase = ''
    substituteInPlace beefi \
      --replace objcopy ${binutils-unwrapped}/bin/objcopy \
      --replace /usr/lib/systemd ${systemd}/lib/systemd
  '';

  meta = {
    description = "Small script to create bootable EFISTUB kernel images";
    homepage = "https://github.com/jfeick/beefi";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ tu-maurice ];
    platforms = lib.platforms.linux;
    mainProgram = "beefi";
  };
})
