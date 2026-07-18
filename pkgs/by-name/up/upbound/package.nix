{
  lib,
  fetchurl,
  installShellFiles,
  stdenvNoCC,
  versionCheckHook,
  version-channel ? "stable",
}:
let
  inherit (stdenvNoCC.hostPlatform) system;
  sources =
    if "${version-channel}" == "main" then
      lib.importJSON ./sources-main.json
    else
      lib.importJSON ./sources-stable.json;
  arch = sources.archMap.${system};

in
stdenvNoCC.mkDerivation {
  pname = if "${version-channel}" == "main" then "upbound-main" else "upbound";
  version = sources.version;
  nativeBuildInputs = [ installShellFiles ];
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp ./${arch}/up $out/bin/up
    chmod +x $out/bin/up

    cp ./${arch}/docker-credential-up $out/bin/docker-credential-up
    chmod +x $out/bin/docker-credential-up

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --bash --name up <(echo complete -C up up)
  '';

  # FIXME: error when running `env -i up`:
  # "up: error: $HOME is not defined"
  doInstallCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  sourceRoot = ".";

  srcs = [
    (fetchurl {
      sha256 = sources.fetchurlAttrSet.docker-credential-up.${system}.hash;
      url = sources.fetchurlAttrSet.docker-credential-up.${system}.url;
    })

    (fetchurl {
      sha256 = sources.fetchurlAttrSet.up.${system}.hash;
      url = sources.fetchurlAttrSet.up.${system}.url;
    })
  ];

  versionCheckProgram = "${placeholder "out"}/bin/up";
  versionCheckProgramArg = "version";

  passthru.updateScript = [
    ./update
    "${version-channel}"
  ];

  meta = {
    description = "CLI for interacting with Upbound Cloud, Upbound Enterprise, and Universal Crossplane (UXP)";
    homepage = "https://upbound.io";
    changelog = "https://docs.upbound.io/reference/release-notes/up-cli";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      lucperkins
      jljox
    ];

    platforms = sources.platformList;
    mainProgram = "up";
  };
}
