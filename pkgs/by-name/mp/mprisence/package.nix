{
  lib,
  fetchFromGitHub,
  dbus,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mprisence";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "lazykern";
    repo = "mprisence";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ss6RXxtpSI3jfq5CAwRLE0XA3tFkIBI+JMyUov2DSpM=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    openssl
  ];

  cargoHash = "sha256-AKj+DibLyoWUw+082m5wMVnZAY4Kmf3+daRJDGeLKtc=";

  meta = {
    description = "Highly customizable Discord Rich Presence for MPRIS media players on Linux";
    homepage = "https://github.com/lazykern/mprisence";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ toasteruwu ];
    mainProgram = "mprisence";
  };
})
