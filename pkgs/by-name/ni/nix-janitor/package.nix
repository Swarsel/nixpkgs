{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nix-janitor";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "nobbz";
    repo = "nix-janitor";
    tag = finalAttrs.version;
    hash = "sha256-MRhTkxPl0tlObbXO7/0cD2pbd9/uQCeRKV3DStGvZMQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-t4TZkwWIp/VYj4tMd5CdYuAQt3GquMRZ3wyAK3oic5k=";

  postInstall = ''
    for shell in bash fish zsh; do
      completionFile=janitor.$shell
      $out/bin/janitor --completions $shell > $completionFile
      installShellCompletion $completionFile
    done
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to clean up old profile generations";
    homepage = "https://github.com/nobbz/nix-janitor";
    changelog = "https://github.com/NobbZ/nix-janitor/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nobbz ];
    platforms = lib.platforms.linux;
    mainProgram = "janitor";
  };
})
