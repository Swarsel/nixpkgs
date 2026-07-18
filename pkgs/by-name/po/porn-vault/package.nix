{
  lib,
  fetchFromGitLab,
  fetchPnpmDeps,
  ffmpeg,
  imagemagick,
  makeWrapper,
  nodejs-slim_22,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  stdenvNoCC,
}:
let
  izzy = rustPlatform.buildRustPackage rec {
    pname = "izzy";
    version = "2.0.1";

    src = fetchFromGitLab {
      owner = "porn-vault";
      repo = "izzy";
      rev = version;
      hash = "sha256-UauA5mZi5a5QF7d17pKSzvyaWbeSuFjBrXEAxR3wNkk=";
    };

    postPatch = ''
      ln -s ${./Cargo.lock} Cargo.lock
    '';

    cargoLock.lockFile = ./Cargo.lock;

    meta = {
      description = "Rust In-Memory K-V Store with Redis-Style File Persistence and Secondary Indices";
      homepage = "https://gitlab.com/porn-vault/izzy";
      license = lib.licenses.gpl3Plus;
      maintainers = [ lib.maintainers.luNeder ];
      mainProgram = "izzy";
    };
  };
  nodejs-slim = nodejs-slim_22;
  pnpm' = pnpm_10.override { inherit nodejs-slim; };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "porn-vault";
  version = "0.30.0-rc.11";

  src = fetchFromGitLab {
    owner = "porn-vault";
    repo = "porn-vault";
    rev = "4c6182c5825d85193cf67cb7cd927da2feaaecdb";
    hash = "sha256-wQ3dqLc0l2BmLGDYrbWxX2mPwO/Tqz0fY/fOQTEUv24=";
  };

  patches = [
    ./allow-use-of-systemd-temp-path.patch
  ];

  postPatch = ''
    substituteInPlace server/binaries/izzy.ts \
      --replace-fail 'chmodSync(izzyPath, "111");' ""
  '';

  nativeBuildInputs = [
    nodejs-slim
    pnpmConfigHook
    pnpm'
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 package.json config.example.json remix.config.js -t $out/share/porn-vault
    cp -R public dist build node_modules graphql locale -t $out/share/porn-vault

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "${lib.getExe nodejs-slim}" "$out/bin/porn-vault" \
      --chdir "$out/share/porn-vault" \
      --add-flags "dist/index.js" \
      --set-default IZZY_PATH "${lib.getExe izzy}" \
      --prefix PATH : "${
        lib.makeBinPath [
          ffmpeg
          imagemagick
          izzy
        ]
      }"
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-5ZMa7/3nbG1xsTfd09oh+NTU+FFhd0lV425pU3s9bZE=";
    pnpm = pnpm';
  };

  meta = {
    inherit (nodejs-slim.meta) platforms;
    description = "Self-hosted organizer for adult videos and imagery";
    homepage = "https://gitlab.com/porn-vault/porn-vault";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.luNeder ];
    mainProgram = "porn-vault";
  };
})
