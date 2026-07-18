{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  makeBinaryWrapper,
  openjpeg,
  pigz,
  replaceVars,
  yaml-cpp,
  batchVersion ? false,
  withCloudflareZlib ? true,
  withJpegLs ? true,
  withOpenJpeg ? true,
  withPigz ? true,
}:

let
  cloudflareZlib = fetchFromGitHub {
    hash = "sha256-WnD9pOnM6J3nCLBKYb28+JaIy0z/9csbn+AsyWZQnLs=";
    owner = "ningfei";
    repo = "zlib";
    # HEAD revision of the gcc.amd64 branch on 2025-10-15. Reminder to update
    # whenever bumping package version.
    rev = "7d9d0b20249fd459c69e4b98bc569b7157f3018c";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dcm2niix";
  version = "1.0.20250506";

  src = fetchFromGitHub {
    owner = "rordenlab";
    repo = "dcm2niix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KtUWrm3Nq3khDxpaQ4W57y+h/gPeEMwfzBv4XYkAhoA=";
  };

  patches = lib.optionals withCloudflareZlib [
    (replaceVars ./dont-fetch-external-libs.patch {
      inherit cloudflareZlib;
    })
  ];

  nativeBuildInputs = [
    cmake
    makeBinaryWrapper
  ];

  buildInputs =
    lib.optionals batchVersion [ yaml-cpp ]
    ++ lib.optionals withOpenJpeg [
      openjpeg
      openjpeg.dev
    ];

  cmakeFlags =
    lib.optionals batchVersion [
      "-DBATCH_VERSION=ON"
      "-DYAML-CPP_DIR=${yaml-cpp}/lib/cmake/yaml-cpp"
    ]
    ++ lib.optionals withJpegLs [
      "-DUSE_JPEGLS=ON"
    ]
    ++ lib.optionals withOpenJpeg [
      "-DUSE_OPENJPEG=ON"
      "-DOpenJPEG_DIR=${openjpeg}/lib/${openjpeg.pname}-${lib.versions.majorMinor openjpeg.version}"
    ]
    ++ lib.optionals withCloudflareZlib [
      "-DZLIB_IMPLEMENTATION=Cloudflare"
    ];

  postInstall = lib.optionalString withPigz ''
    wrapProgram $out/bin/dcm2niix --prefix PATH : "${lib.makeBinPath [ pigz ]}"
  '';

  meta = {
    description = "DICOM to NIfTI converter";

    longDescription = ''
      dcm2niix is designed to convert neuroimaging data from the DICOM format to the NIfTI format.
    '';

    homepage = "https://www.nitrc.org/projects/dcm2nii";
    changelog = "https://github.com/rordenlab/dcm2niix/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      ashgillman
      rbreslow
    ];

    platforms = lib.platforms.all;
    mainProgram = "dcm2niix";
  };
})
