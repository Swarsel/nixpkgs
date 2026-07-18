{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  vulkan-loader,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hayabusa";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "notarin";
    repo = "hayabusa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w9vXC7L7IP4QLPFS1IgPOKSm7fT7W0R+NsHTdAfIupg=";
  };

  postPatch = ''
    substituteInPlace distribution/hayabusa.service \
      --replace "/usr/local" "$out"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    vulkan-loader
  ];

  cargoHash = "sha256-F1dUv1SR6cf1o6a2JG2i2fCgjZpGsG20mskIrf3oiHY=";

  postInstall = ''
    install -Dm444 distribution/hayabusa.service -t $out/lib/systemd/system/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Swift rust fetch program";
    homepage = "https://github.com/notarin/hayabusa";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ Notarin ];
    platforms = lib.platforms.linux;
    mainProgram = "hayabusa";
  };
})
