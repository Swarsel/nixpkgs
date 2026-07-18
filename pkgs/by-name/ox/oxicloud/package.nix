{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeBinaryWrapper,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oxicloud";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "AtalayaLabs";
    repo = "OxiCloud";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9bUfHSBXEEwU35J7zXdpS7zPKOFyCerQq5WQ6rO5tag=";
  };

  postPatch = ''
    # Upstream pins `target-cpu=native`, making the binary non-portable
    # (breaks the binary cache). Build for the generic baseline instead.
    rm -f .cargo/config.toml
  '';

  nativeBuildInputs = [
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-M3gl00jSvykx6+ewbvgEZiNL9bDDjfnq089nYXiwEiQ=";

  postInstall = ''
    mkdir -p $out/share/oxicloud
  '';

  postFixup = ''
    wrapProgram $out/bin/oxicloud \
      --set-default OXICLOUD_STATIC_PATH ${finalAttrs.oxicloud-front}
  '';

  __structuredAttrs = true;
  cargoBuildFlags = [ "--bin=oxicloud" ];

  oxicloud-front = buildNpmPackage (frontFinalAttrs: {
    inherit (finalAttrs) version src;
    pname = "oxicloud-front";

    postPatch = ''
      substituteInPlace svelte.config.js \
        --replace "'../static-dist'" "'static-dist'"
    '';

    npmDepsHash = "sha256-dn9vEk84AYaqfhBhf2obsfQBYUPkE5qyjXalFNNziXw=";

    installPhase = ''
      runHook preInstall
      cp -r static-dist $out
      runHook postInstall
    '';

    sourceRoot = "${frontFinalAttrs.src.name}/frontend";
  });

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "oxicloud-front"
    ];
  };

  meta = {
    description = "Ultra-fast, secure & lightweight self-hosted cloud storage";
    homepage = "https://github.com/AtalayaLabs/OxiCloud";
    changelog = "https://github.com/AtalayaLabs/OxiCloud/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flashonfire ];
    platforms = lib.platforms.linux;
    mainProgram = "oxicloud";
  };
})
