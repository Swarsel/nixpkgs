{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wl-clip-persist";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Linus789";
    repo = "wl-clip-persist";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MEH8ADsFst/CgTc9QW4x0dBXJ5ssQDVa55qPcsALJRg=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ wayland ];
  cargoHash = "sha256-iQI5Z/gk+EFNQNma+T2/y77F8M+kPuSS2QKO6QV9dm4=";

  meta = {
    inherit (wayland.meta) platforms;
    description = "Keep Wayland clipboard even after programs close";
    homepage = "https://github.com/Linus789/wl-clip-persist";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ name-snrl ];
    mainProgram = "wl-clip-persist";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
