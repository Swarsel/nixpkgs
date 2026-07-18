{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vazirmatn";
  version = "33.003";

  src = fetchFromGitHub {
    owner = "rastikerdar";
    repo = "vazirmatn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C1UtfrRFzz0uv/hj8e7huXe4sNd5h7ozVhirWEAyXGg=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  strictDeps = true;
  nativeBuildInputs = [ installFonts ];

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  __structuredAttrs = true;
  dontBuild = true;

  meta = {
    description = "Persian (Farsi) Font - قلم (فونت) فارسی وزیرمتن";
    homepage = "https://github.com/rastikerdar/vazirmatn";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
