{
  lib,
  fetchFromGitHub,
  libfaketime,
  makeBinaryWrapper,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "skewrun";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "JVBotelho";
    repo = "skewrun";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C4LF2am3gnQb+k9cdfB2xcszZ5imRBwz0ldP0gjfXRs=";
  };

  buildInputs = [
    libfaketime
    makeBinaryWrapper
  ];

  cargoHash = "sha256-hGJvirVLtP1ondLxJuyfiV7Y0+pGt8Pu3lzLAhRYtoo=";

  postFixup = ''
    wrapProgram $out/bin/skewrun --prefix PATH : "${
      lib.makeBinPath [
        libfaketime
      ]
    }"
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Active Directory time discovery toolkit";
    homepage = "https://github.com/JVBotelho/skewrun";
    changelog = "https://github.com/JVBotelho/skewrun/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "skewrun";
  };
})
