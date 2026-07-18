{
  lib,
  fetchFromGitHub,
  libpcap,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "netop";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "ZingerLittleBee";
    repo = "netop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Rnp2VNAi8BNbKqkGFoYUb4C5db5BS1P1cqpWlroTmdQ=";
  };

  cargoHash = "sha256-WGwtRMARwRvcUflN3JYL32aib+IG1Q0j0D9BEfaiME4=";

  env = {
    LIBPCAP_LIBDIR = lib.makeLibraryPath [ libpcap ];
    LIBPCAP_VER = libpcap.version;
  };

  meta = {
    description = "Network monitor using bpf";
    homepage = "https://github.com/ZingerLittleBee/netop";
    changelog = "https://github.com/ZingerLittleBee/netop/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.marcusramberg ];
    platforms = lib.platforms.linux;
    mainProgram = "netop";
  };
})
