{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  fetchpatch,
  meson,
  ninja,
  pkg-config,
  uthash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdicom";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "ImagingDataCommons";
    repo = "libdicom";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-9n0Gp9+fmTM/shgWC8zpwt1pic9BrvDubOt7f+ZDMeE=";
  };

  patches = [
    (fetchpatch {
      excludes = [ "CHANGELOG.md" ];
      hash = "sha256-/KTp0nKYk6jX4phNHY+nzjEptUBHKM2JkOftS5vHsEw=";
      name = "CVE-2024-24793.CVE-2024-24794.patch";
      url = "https://github.com/ImagingDataCommons/libdicom/commit/3661aa4cdbe9c39f67d38ae87520f9e3ed50ab16.patch";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ]
  ++ lib.optionals (finalAttrs.finalPackage.doCheck) [ check ];

  buildInputs = [ uthash ];
  mesonFlags = lib.optionals (!finalAttrs.finalPackage.doCheck) [ "-Dtests=false" ];
  doCheck = true;
  mesonBuildType = "release";

  meta = {
    description = "C library for reading DICOM files";
    homepage = "https://github.com/ImagingDataCommons/libdicom";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lromor ];
    platforms = lib.platforms.unix;
  };
})
