{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch2,
  lv2,
  lv2lint,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fomp";
  version = "1.2.4";

  src = fetchFromGitLab {
    owner = "drobilla";
    repo = "fomp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8rkAV+RJS9vQV+9+swclAP0QBjBDT2tKeLWHxwpUrlk=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-uJpUwTEBOp0Zo7zKT9jekhtkg9okUvGTavLIQmNKutU=";
      url = "https://gitlab.com/drobilla/fomp/-/commit/f8e4e1e0b1abe3afd2ea17b13795bbe871fccece.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    lv2lint
  ];

  buildInputs = [
    lv2
  ];

  meta = {
    description = "LV2 port of the MCP, VCO, FIL, and WAH plugins by Fons Adriaensen";
    homepage = "https://drobilla.net/software/fomp.html";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
