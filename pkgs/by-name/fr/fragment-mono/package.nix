{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fragment-mono";
  version = "1.21";

  src = fetchzip {
    url = "https://github.com/weiweihuanghuang/fragment-mono/releases/download/${finalAttrs.version}/fragment-mono-${finalAttrs.version}.zip";
    hash = "sha256-H5s4rYDN2d0J+zVRgBzg8vfZXCA/jjHrGBV8o8Dxutc=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Helvetica Monospace Coding Font";

    longDescription = ''
      Fragment Mono is a monospaced coding version of Helvetica created
      by modifying and extending Nimbus Sans by URW Design Studio.
    '';

    homepage = "https://github.com/weiweihuanghuang/fragment-mono";
    changelog = "https://github.com/weiweihuanghuang/fragment-mono/releases/tag/${finalAttrs.version}";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.noahgitsham ];
    platforms = lib.platforms.all;
  };
})
