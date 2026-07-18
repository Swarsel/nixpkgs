{
  lib,
  fetchFromGitHub,
  makeWrapper,
  rustPlatform,
  nvidiaSupport ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zenith";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "bvaisvil";
    repo = "zenith";
    rev = finalAttrs.version;
    hash = "sha256-NOQ+LqymP1VQ80up6XR7kBYRfWey82wbDbGkf1NsQhc=";
  };

  # remove cargo config so it can find the linker on aarch64-linux
  postPatch = ''
    rm .cargo/config.toml
  '';

  nativeBuildInputs = [ rustPlatform.bindgenHook ] ++ lib.optional nvidiaSupport makeWrapper;
  cargoHash = "sha256-OABHxLLysx/atZBWCMJCcypugzs5OFtRp2KW3dkp2DE=";

  postInstall = lib.optionalString nvidiaSupport ''
    wrapProgram $out/bin/zenith \
      --suffix LD_LIBRARY_PATH : "/run/opengl-driver/lib"
  '';

  buildFeatures = lib.optional nvidiaSupport "nvidia";

  meta = {
    description =
      "Sort of like top or htop but with zoom-able charts, network, and disk usage"
      + lib.optionalString nvidiaSupport ", and NVIDIA GPU usage";

    homepage = "https://github.com/bvaisvil/zenith";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = if nvidiaSupport then lib.platforms.linux else lib.platforms.unix;
    mainProgram = "zenith";
  };
})
