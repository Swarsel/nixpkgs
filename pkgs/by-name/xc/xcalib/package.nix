{
  lib,
  stdenv,
  cmake,
  fetchFromCodeberg,
  fetchpatch,
  libx11,
  libxrandr,
  libxxf86vm,
  ninja,
  samurai,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xcalib";
  version = "0.11";

  src = fetchFromCodeberg {
    owner = "OpenICC";
    repo = "xcalib";
    tag = finalAttrs.version;
    hash = "sha256-o0pizV4Qrb9wfVKVNH2Ifb9tr7N7iveVHQB39WVCl8w=";
  };

  patches = [
    # bump min cmake to v3.5
    (fetchpatch {
      hash = "sha256-gZc4itfsP5T68ZucdYJWJ4sL11xFaw5ePABsmEYHxrU=";
      url = "https://codeberg.org/OpenICC/xcalib/commit/e8566ead8c043b5f0003c3613b91deab6430eac8.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libx11
    libxxf86vm
    libxrandr
    samurai
  ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Tiny monitor calibration loader for X and MS-Windows";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "xcalib";
  };
})
