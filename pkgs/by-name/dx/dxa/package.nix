{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dxa";
  version = "0.1.5";

  src = fetchurl {
    hash = "sha256-jkDtd4FlgfmtlaysLtaaL7KseFDkM9Gc1oQZOkWCZ5k=";

    urls = [
      "https://www.floodgap.com/retrotech/xa/dists/dxa-${finalAttrs.version}.tar.gz"
      "https://www.floodgap.com/retrotech/xa/dists/unsupported/dxa-${finalAttrs.version}.tar.gz"
    ];
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "CC = gcc" "CC = ${stdenv.cc.targetPrefix}cc"
  '';

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -T dxa $out/bin/dxa
    installManPage dxa.1

    runHook postInstall
  '';

  dontConfigure = true;

  meta = {
    description = "Andre Fachat's open-source 6502 disassembler";
    homepage = "https://www.floodgap.com/retrotech/xa/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
    mainProgram = "dxa";
  };
})
