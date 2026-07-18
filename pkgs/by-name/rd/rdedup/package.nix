{
  lib,
  fetchFromGitHub,
  libsodium,
  openssl,
  pkg-config,
  rustPlatform,
  xz,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rdedup";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "dpc";
    repo = "rdedup";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-GEYP18CaCQShvCg8T7YTvlybH1LNO34KBxgmsTv2Lzs=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    libsodium
    xz
  ];

  cargoHash = "sha256-JpsUceR9Y3r6RiaLOtbgBUrb6eoan7fFt76U9ztQoM8=";

  meta = {
    description = "Data deduplication with compression and public key encryption";
    homepage = "https://github.com/dpc/rdedup";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ dywedir ];
    mainProgram = "rdedup";
  };
})
