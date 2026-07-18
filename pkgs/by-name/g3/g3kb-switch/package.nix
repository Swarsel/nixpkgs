{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "g3kb-switch";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "lyokha";
    repo = "g3kb-switch";
    rev = finalAttrs.version;
    hash = "sha256-kTJfV0xQmWuxibUlfC1qJX2J2nrZ4wimdf/nGciQq0Y=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  meta = {
    description = "CLI keyboard layout switcher for GNOME Shell";
    homepage = "https://github.com/lyokha/g3kb-switch";
    changelog = "https://github.com/lyokha/g3kb-switch/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ Freed-Wu ];
    platforms = lib.platforms.unix;
    mainProgram = "g3kb-switch";
  };
})
