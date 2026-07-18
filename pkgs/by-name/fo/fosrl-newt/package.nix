{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "newt";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "fosrl";
    repo = "newt";
    tag = finalAttrs.version;
    hash = "sha256-WjjXtx2csUAzQ1h3Ey2axaYdsn8pTeyxYByiTfBURos=";
  };

  vendorHash = "sha256-JhNBJhj5YX3Wurv7r/JDu6YtHizOMLk+NCob7ISx+3c=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X=main.newtVersion=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tunneling client for Pangolin";
    homepage = "https://github.com/fosrl/newt";
    changelog = "https://github.com/fosrl/newt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      fab
      jackr
      water-sucks
    ];

    mainProgram = "newt";
    # Networking failures in tests, even with __darwinAllowLocalNetworking on
    # and sandbox disabled.
    # Unclear as of 2026-04-24 whether the program works if tests are disabled.
    broken = stdenv.hostPlatform.isDarwin;
  };
})
