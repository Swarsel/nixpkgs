{
  lib,
  fetchgit,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bleur";
  version = "0.0.7";

  src = fetchgit {
    url = "https://git.oss.uzinfocom.uz/bleur/bleur.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bFpOvnC2MILr3b+KdVOAvDGmEZM8LDlwGd04csk2l18=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-edeegm0QeXqj0E46+BHcmJMU1Ewn6p9hi3WArDtyVnI=";
  __structuredAttrs = true;

  meta = {
    description = "Template manager & buddy for bleur templates by Orzklv";
    homepage = "https://bleur.uz/";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [
      orzklv
      bahrom04
      wolfram444
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "bleur";
  };
})
