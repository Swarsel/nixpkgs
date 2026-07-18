{
  lib,
  stdenv,
  fetchFromGitLab,
  giflib,
  hexdump,
  libdrm,
  libexif,
  libiconvReal,
  libinput,
  libtsm,
  libwebp,
  libxkbcommon,
  libxpm,
  libxt,
  meson,
  motif,
  ninja,
  perl,
  pixman,
  pkg-config,
  poppler,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fbida";
  version = "2.15-1";

  src = fetchFromGitLab {
    owner = "kraxel";
    repo = "fbida";
    tag = "fbida-${finalAttrs.version}";
    hash = "sha256-iwJkFynhz3SJ8MRjUsKtQAjPCBvST1ezsxTw2ZCXBag=";
  };

  patches = [
    # Prevents using function declaration without explicit parameters.
    ./function-parameters.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    hexdump
    meson
    ninja
    perl
    pkg-config
  ];

  buildInputs = [
    giflib
    libdrm
    libexif
    libiconvReal
    libinput
    libtsm
    libwebp
    libxkbcommon
    libxpm
    libxt
    motif
    pixman
    poppler
    udev
  ];

  makeFlags = [
    "HOST=nix"
  ];

  __structuredAttrs = true;

  patchPhase = ''
    runHook prePatch

    patchShebangs scripts/*.pl
    patchShebangs scripts/*.sh

    sed -i -E \
      -e '/^jpeg_run[[:space:]]*=.*$/d' \
      -e "/^jpeg_ver[[:space:]]*=.*$/c\\jpeg_ver = '62'" \
      meson.build

    runHook postPatch
  '';

  meta = {
    description = "Image viewing and manipulation programs including fbi, fbgs, ida, exiftran and thumbnail.cgi";
    homepage = "https://www.kraxel.org/blog/linux/fbida/";
    changelog = "https://gitlab.com/kraxel/fbida/-/blob/${finalAttrs.src.tag}/Changes?ref_type=tags";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
    downloadPage = "https://gitlab.com/kraxel/fbida/";
  };
})
