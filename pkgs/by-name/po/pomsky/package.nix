{
  lib,
  fetchFromGitHub,
  nix-update-script,
  oniguruma,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pomsky";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "pomsky-lang";
    repo = "pomsky";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0rLY0WZj8p9D834SqHogV77GLHLesyPPxMGszDmkB9U=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    oniguruma
  ];

  cargoHash = "sha256-zUK8v96/jHaprrfbym23X7e/ZRoDwfNyDt+GIcd7BmY=";

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  # Compatibility tests run against different regex implementations.
  # Some can be run by providing `jdk*_headless` and `python3` `nativeCheckInputs`,
  # while some cannot, i.e. `deno`-based requires network access and `dotnet-script` is not packaged,
  # and they cannot be disabled partially.
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Portable, modern regular expression language";
    homepage = "https://pomsky-lang.org";
    changelog = "https://github.com/pomsky-lang/pomsky/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "pomsky";
  };
})
