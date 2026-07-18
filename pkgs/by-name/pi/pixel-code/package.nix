{
  lib,
  fetchFromGitHub,
  installFonts,
  python3,
  stdenvNoCC,
  woff2,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pixel-code";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "qwerasd205";
    repo = "PixelCode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jpOj6MndjCTTPESIjh3VJW1FKK5n99W8GBgPqloaKFM=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  postPatch = ''
        substituteInPlace src/build.sh \
          --replace-fail \
    '# Activate python virtual environment.
    ../activate.sh
    source ../.venv/bin/activate' ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    (python3.withPackages (
      ps: with ps; [
        fontmake
        fonttools
        ufolib2
        pillow
      ]
    ))
    woff2
    installFonts
  ];

  buildPhase = ''
    runHook preBuild
    src/build.sh
    runHook postBuild
  '';

  meta = {
    description = "Pixel font designed to actually be good for programming";
    homepage = "https://github.com/qwerasd205/PixelCode";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ mattpolzin ];
  };
})
