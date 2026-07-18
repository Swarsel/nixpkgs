{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "figtree";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "erikdkennedy";
    repo = "figtree";
    tag = "v${finalAttrs.version}";
    hash = "sha256-owzoM0zfKYxLJCQbL1eUE0cdSLVmm+QNRUGxbsNJ37I=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];
  sourceRoot = "source/fonts";

  meta = {
    description = "Simple and friendly geometric sans serif font";
    homepage = "https://github.com/erikdkennedy/figtree";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      mrcjkb
      ners
    ];

    platforms = lib.platforms.all;
  };
})
