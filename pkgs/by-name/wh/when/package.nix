{
  lib,
  fetchFromBitbucket,
  installShellFiles,
  perl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "when";
  version = "1.1.45";

  src = fetchFromBitbucket {
    owner = "ben-crowell";
    repo = "when";
    rev = finalAttrs.version;
    hash = "sha256-+ggYjY6/aTUrdvREn0TTQ4Pu/VR4QTjflDaicRXuOMs=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ perl ];

  postBuild = ''
    pod2man $src/when when.1
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 when $out/bin/when
    installManPage when.1

    runHook postInstall
  '';

  meta = {
    description = "Extremely simple personal calendar program";
    homepage = "https://www.lightandmatter.com/when/when.html";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ vonixxx ];
    platforms = lib.platforms.all;
    mainProgram = "when";
  };
})
