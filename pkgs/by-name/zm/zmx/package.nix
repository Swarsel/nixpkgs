{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk,
  installShellFiles,
  nix-update-script,
  writeShellScriptBin,
  zig_0_15,
}:
let
  zig = zig_0_15;

  sdkRoot = apple-sdk.sdkroot;
  # Ghostty's Zig build asks Zig to discover the native Darwin SDK via
  # std.zig.LibCInstallation.findNative, which shells out to xcrun/xcode-select
  # on macOS. Provide wrappers so this works inside the Nix sandbox.
  xcrunWrapper = writeShellScriptBin "xcrun" ''
    echo "${sdkRoot}"
  '';
  xcodeselectWrapper = writeShellScriptBin "xcode-select" ''
    echo "${sdkRoot}"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zmx";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "neurosnap";
    repo = "zmx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OkXtVf/LdBrZL6FH9TGx+mIhUXt2eSugLxZyMd+HL6k=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    zig
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xcrunWrapper
    xcodeselectWrapper
  ];

  postConfigure = ''
    # Zig may write cache metadata next to fetched dependencies while checking them.
    cp -rLT ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
    chmod -R u+w "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  doCheck = true;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
      --bash <($out/bin/zmx completions bash) \
      --zsh <($out/bin/zmx completions zsh) \
      --fish <($out/bin/zmx completions fish)
  '';

  __structuredAttrs = true;

  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) src pname version;
    fetchAll = true;
    hash = "sha256-TwKoeaE4g5G7t7smKoqHkCCh998nSqKx5k6sO2vDlGs=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Session persistence for terminal processes";

    longDescription = ''
      zmx provides session persistence for terminal shell sessions (pty processes).
      Features include ability to attach and detach from shell sessions without killing them,
      native terminal scrollback, multiple client connections to the same session,
      and restoration of previous terminal state and output when re-attaching.
    '';

    homepage = "https://github.com/neurosnap/zmx";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dwt
      GabrielDougherty
    ];

    platforms = lib.platforms.unix;
    mainProgram = "zmx";
  };
})
