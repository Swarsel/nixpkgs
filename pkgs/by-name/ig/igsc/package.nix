{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  metee,
  nix-update-script,
  udev,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "igsc";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "igsc";
    tag = "V${finalAttrs.version}";
    hash = "sha256-GdeGGrnkxJQlg+vVQan5rJW/rxlStD4TAmWxfloX0+k=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    metee
    udev
  ];

  cmakeFlags = [
    "-DMETEE_LIB_PATH=${metee}/lib"
    "-DMETEE_HEADER_PATH=${metee}/include"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Intel graphics system controller firmware update library";
    homepage = "https://github.com/intel/igsc";
    changelog = "https://github.com/intel/igsc/releases/tag/V${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.linux;
    mainProgram = "igsc";
  };
})
