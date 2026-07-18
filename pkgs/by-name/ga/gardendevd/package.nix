{
  lib,
  stdenv,
  acl,
  elogind,
  fetchFromCodeberg,
  kmod,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  util-linux,
  uaccessSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gardendevd";
  version = "0.2";

  src = fetchFromCodeberg {
    owner = "Gardenhouse";
    repo = "gardendevd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aEG2QIRFH3F5tXBD1U+6SNmOpUMHgdhH7AXwyGGrilI=";
  };

  postPatch = ''
    substituteInPlace src/rules-builtin.c \
      --replace-fail "/sbin/blkid" "${util-linux}/bin/blkid" \
      --replace-fail "/sbin/modprobe" "${kmod}/bin/modprobe"
    substituteInPlace src/rules-parse.c \
      --replace-fail "/usr/lib/udev/rules.d" "$out/lib/udev/rules.d"
    substituteInPlace src/spawn.c \
      --replace-fail "/usr/lib/udev/" "$out/lib/udev/"

    patchShebangs scripts/
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = lib.optionals uaccessSupport [
    acl
    elogind
  ];

  mesonFlags = [
    "-Dopenrc=disabled"
    (lib.mesonEnable "uaccess" uaccessSupport)
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Udev daemon running on top of mdevd to replace systemd-udev";

    longDescription = ''
      Gardendevd is a udev-compatible daemon that processes device
      events from the Linux kernel. It is designed to be a lightweight
      and flexible alternative to systemd-udevd, leveraging mdevd for
      device node creation and firmware loading.
    '';

    homepage = "https://codeberg.org/Gardenhouse/gardendevd";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      aanderse
      choco98
    ];

    platforms = lib.platforms.linux;
  };
})
