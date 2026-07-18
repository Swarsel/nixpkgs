{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zuban";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "zubanls";
    repo = "zuban";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g06iHdbKb/uZkGkbX7fHB0MMDbuYYnGodQAEPvA18KA=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-bfiWuig9ySkbJ/2CL4jGlNYn/YvVClB3Eg0cq8dKi3E=";

  postInstall = ''
    mkdir -p $out/${python3.sitePackages}/zuban
    cp -r third_party $out/${python3.sitePackages}/zuban/
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildAndTestSubdir = "crates/zuban";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Mypy-compatible Python Language Server built in Rust";
    homepage = "https://zubanls.com";
    # There's no changelog file yet, but they post updates on their blog.
    changelog = "https://zubanls.com/blog/";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      bew
      mcjocobe
    ];

    platforms = lib.platforms.all;
    mainProgram = "zuban";
  };
})
