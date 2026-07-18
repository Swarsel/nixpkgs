{
  lib,
  stdenv,
  fetchurl,
  curl,
  glibc,
  ncurses,
  openssl,
  p7zip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vk-cli";
  version = "0.7.6";

  src = fetchurl {
    url = "https://github.com/vk-cli/vk/releases/download/${finalAttrs.version}/vk-${finalAttrs.version}-64-bin.7z";
    sha256 = "sha256-Y40oLjddunrd7ZF1JbCcgjSCn8jFTubq69jhAVxInXw=";
  };

  nativeBuildInputs = [
    p7zip
  ];

  buildInputs = [
    curl
    ncurses
    openssl
  ];

  installPhase = ''
    mkdir -p $out/bin/
    mv $TMP/vk-${finalAttrs.version}-64-bin vk-cli
    install -D vk-cli --target-directory=$out/bin/
  '';

  postFixup = ''
    patchelf $out/bin/vk-cli \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${
        lib.makeLibraryPath [
          curl
          glibc
        ]
      }"
  '';

  unpackPhase = ''
    mkdir -p $TMP/
    7z x $src -o$TMP/
  '';

  meta = {
    description = "Console (ncurses) client for vk.com written in D";
    homepage = "https://github.com/vk-cli/vk";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "vk-cli";
  };
})
