{
  lib,
  stdenv,
  fetchFromGitHub,
  # linux-only
  bubblewrap,
  buildNpmPackage,
  nix-update-script,
  # runtime dependencies
  ripgrep,
  socat,
  versionCheckHook,
  which,
}:

buildNpmPackage (finalAttrs: {
  pname = "sandbox-runtime";
  version = "0.0.64";

  src = fetchFromGitHub {
    owner = "anthropic-experimental";
    repo = "sandbox-runtime";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kKXGZcK3hx3ugud+DxLrBC+IwnUzEe0Gae2lq7DU8hA=";
  };

  postPatch =
    # Fix the `--version` flag.
    ''
      substituteInPlace src/cli.ts \
        --replace-fail "1.0.0" "${finalAttrs.version}"
    '';

  strictDeps = true;
  npmDepsHash = "sha256-3HOGoIG9syQJ407C8Bg7J7mtPpoIjVtUoFCdbSmT8BU=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup =
    let
      runtimeDeps = [
        ripgrep
        which
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        bubblewrap
        socat
      ];
    in
    ''
      wrapProgram $out/bin/srt \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}
    '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight sandboxing tool for enforcing filesystem and network restrictions on arbitrary processes at the OS level, without requiring a container";
    homepage = "https://github.com/anthropic-experimental/sandbox-runtime";
    changelog = "https://github.com/anthropic-experimental/sandbox-runtime/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "srt";
  };
})
