{
  lib,
  stdenv,
  libdrm,
  meson,
  ninja,
  patches,
  pkg-config,
  src,
  version,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version src patches;
  pname = "libliftoff";

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [ libdrm ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Lightweight KMS plane library";

    longDescription = ''
      libliftoff eases the use of KMS planes from userspace without standing in
      your way. Users create "virtual planes" called layers, set KMS properties
      on them, and libliftoff will pick planes for these layers if possible.
    '';

    changelog = "https://gitlab.freedesktop.org/emersion/libliftoff/-/tags/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Scrumplex
    ];

    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
  };
})
