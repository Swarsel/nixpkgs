{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  itk,
  makeBinaryWrapper,
  vtk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ANTs";
  version = "2.6.5";

  src = fetchFromGitHub {
    owner = "ANTsX";
    repo = "ANTs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6ncoXhIlEjZL7ABdqpupM7ebWKYeUits37SbT0Jr1Lk=";
  };

  nativeBuildInputs = [
    cmake
    makeBinaryWrapper
  ];

  buildInputs = [
    itk
    vtk
  ];

  cmakeFlags = [
    "-DANTS_SUPERBUILD=FALSE"
    "-DUSE_VTK=TRUE"
  ];

  postInstall = ''
    for file in $out/bin/*; do
      wrapProgram $file --prefix PATH : "$out/bin"
    done
  '';

  meta = {
    description = "Advanced normalization toolkit for medical image registration and other processing";
    homepage = "https://github.com/ANTsX/ANTs";
    changelog = "https://github.com/ANTsX/ANTs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
    mainProgram = "antsRegistration";
  };
})
