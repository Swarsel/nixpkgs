{
  lib,
  stdenv,
  fetchurl,
  zstd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "docker-init";
  version = "1.4.0";

  src = fetchurl {
    url = "https://desktop.docker.com/linux/main/amd64/${finalAttrs.tag}/docker-desktop-x86_64.pkg.tar.zst";
    hash = "sha256-pxxlSN2sQqlPUzUPufcK8T+pvdr0cK+9hWTYzwMJv5I=";
  };

  nativeBuildInputs = [
    zstd
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,libexec/docker/cli-plugins}

    cp usr/lib/docker/cli-plugins/docker-init $out/libexec/docker/cli-plugins
    ln -s $out/libexec/docker/cli-plugins/docker-init $out/bin/docker-init
    runHook postInstall
  '';

  tag = "175267";

  unpackPhase = ''
    runHook preUnpack
    tar --zstd -xvf $src
    runHook postUnpack
  '';

  meta = {
    description = "Creates Docker-related starter files for your project";
    homepage = "https://docs.docker.com/reference/cli/docker/init";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ BastianAsmussen ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "docker-init";
    downloadPage = "https://docs.docker.com/desktop/release-notes";
  };
})
