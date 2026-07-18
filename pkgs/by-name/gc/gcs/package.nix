{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  mupdf,
  nix-update-script,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "gcs";
  version = "5.42.0";

  src = fetchFromGitHub {
    owner = "richardwilkes";
    repo = "gcs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eCWMaO1iv917aHcdln2B10oCSbmzpXvQIF/luztHwRc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    mupdf
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libGL
    libx11
    libxcursor
    libxrandr
    libxinerama
    libxi
    libxxf86vm
    fontconfig
    freetype
  ];

  vendorHash = "sha256-pbt4zNbFYTXKVe9D70Lg3XVsjadnUIuPwbbV1CJNLc8=";

  installPhase = ''
    runHook preInstall
    install -Dm755 $GOPATH/bin/gcs -t $out/bin
    runHook postInstall
  '';

  # flags are based on https://github.com/richardwilkes/gcs/blob/master/build.sh
  flags = [ "-a" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/richardwilkes/toolbox/cmdline.AppVersion=${finalAttrs.version}"
  ];

  modPostBuild = ''
    chmod +w vendor/github.com/richardwilkes/pdf
    sed -i 's|-lmupdf[^ ]* |-lmupdf |g' vendor/github.com/richardwilkes/pdf/pdf.go
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Stand-alone, interactive, character sheet editor for the GURPS 4th Edition roleplaying game system";
    homepage = "https://gurpscharactersheet.com/";
    changelog = "https://github.com/richardwilkes/gcs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "gcs";
    # incompatible vendor/github.com/richardwilkes/unison/internal/skia/libskia_linux.a
    broken = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64;
  };
})
