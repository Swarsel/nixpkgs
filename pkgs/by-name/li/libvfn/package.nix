{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  nix-update-script,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvfn";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "SamsungDS";
    repo = "libvfn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CEVjJVeDEEJcJX2/6fwKGBHDsxgN+pL7fJWvQ+iCh3Y=";
  };

  postPatch = ''
    patchShebangs scripts/trace.pl scripts/ctags.sh scripts/sparse.py
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    perl
  ];

  mesonFlags = [
    (lib.mesonEnable "docs" false)
    (lib.mesonEnable "libnvme" false)
    (lib.mesonBool "profiling" false)
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Zero-dependency library for interacting with PCIe-based NVMe devices from user-space";

    longDescription = ''
      libvfn is a zero-dependency library for interacting with PCIe-based NVMe
      devices from user-space using the Linux kernel vfio-pci driver. The core
      of the library is excessively low-level and aims to allow controller
      verification and testing teams to interact with the NVMe device at the
      register and queue level.
    '';

    homepage = "https://github.com/SamsungDS/libvfn";
    license = lib.licenses.lgpl21Plus;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [ joelgranados ];

    # Explicit list of tested platforms. The abstractions on other platforms
    # are untested and might not work. More will be added as we test them.
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
