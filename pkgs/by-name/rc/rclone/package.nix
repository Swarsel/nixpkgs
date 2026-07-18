{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  fuse3,
  installShellFiles,
  librclone,
  macfuse-stubs,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
  enableCmount ? true,
}:

buildGoModule (finalAttrs: {
  pname = "rclone";
  version = "1.74.4";

  src = fetchFromGitHub {
    owner = "rclone";
    repo = "rclone";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n+s9OiSwjiFwR1/DEd81YZIAyaMWMj0g8ORf6grnE3M=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  buildInputs = lib.optional enableCmount (
    # cgofuse uses the fuse2 header locations on darwin
    if stdenv.hostPlatform.isDarwin then (macfuse-stubs.override { isFuse3 = false; }) else fuse3
  );

  vendorHash = "sha256-PVTcYFRr4Zb4VVsY6dkO+emZ48Nyr9aUBJbehFlDh9c=";

  postConfigure = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    substituteInPlace vendor/github.com/winfsp/cgofuse/fuse/host_cgo.go \
        --replace-fail "fuse.h" "fuse3/fuse.h"
  '';

  postInstall =
    let
      rcloneBin =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          "$out"
        else
          lib.getBin buildPackages.rclone;
    in
    ''
      installManPage rclone.1
      for shell in bash zsh fish; do
        ${rcloneBin}/bin/rclone genautocomplete $shell rclone.$shell
        installShellCompletion rclone.$shell
      done

      # filesystem helpers
      ln -s $out/bin/rclone $out/bin/rclonefs
      ln -s $out/bin/rclone $out/bin/mount.rclone
    ''
    +
      lib.optionalString (enableCmount && !stdenv.hostPlatform.isDarwin)
        # use --suffix here to ensure we don't shadow /run/wrappers/bin/fusermount3,
        # as the setuid wrapper is required as non-root on NixOS.
        ''
          wrapProgram $out/bin/rclone \
            --suffix PATH : "${lib.makeBinPath [ fuse3 ]}"
        '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/rclone/rclone/fs.Version=${finalAttrs.src.tag}"
  ];

  subPackages = [ "." ];

  tags =
    lib.optionals (!stdenv.hostPlatform.isDarwin) [ "fuse3" ]
    ++ lib.optionals enableCmount [ "cmount" ];

  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  versionCheckProgramArg = "version";

  passthru = {
    tests = {
      inherit librclone;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Command line program to sync files and directories to and from major cloud storage";
    homepage = "https://rclone.org";
    changelog = "https://github.com/rclone/rclone/blob/v${finalAttrs.version}/docs/content/changelog.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      SuperSandro2000
    ];

    mainProgram = "rclone";
  };
})
