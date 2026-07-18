{
  lib,
  stdenv,
  fetchFromGitHub,
  cmocka,
  fetchpatch2,
  libusb1,
  libxml2,
  libzip,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qdl";
  version = "2.7";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "qdl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oZ/1Pe81VOAmZiywSC2jC1OcDtaH84GAuo8AqiE77d4=";
  };

  patches = [
    # allow VERSION to be overridden, will land in 2.8
    (fetchpatch2 {
      hash = "sha256-fDC34Wq4MadDDLHVQ5zuRKE2zD2dOMTU8EGINcJTYuI=";
      url = "https://github.com/linux-msm/qdl/commit/6f8700ed81b3614baa12786a9845c9abeab1e178.patch";
    })
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    cmocka
    ninja
  ];

  buildInputs = [
    libxml2
    libusb1
    libzip
  ];

  mesonFlags = [
    "--prefix=${placeholder "out"}"
    "-DVERSION=${finalAttrs.src.rev}"

    # Tests currently fail to link but seem rather new
    # https://github.com/linux-msm/qdl/issues/260
    # test_contents_selectors.c:(.text+0x234e): undefined reference to `firehose_alloc_op'
    "-Dtests=disabled"
  ];

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for flashing images to Qualcomm devices";
    homepage = "https://github.com/linux-msm/qdl";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      muscaln
      anas
      numinit
    ];

    platforms = lib.platforms.linux;
    mainProgram = "qdl";
  };
})
