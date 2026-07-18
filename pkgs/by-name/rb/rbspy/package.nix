{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ruby,
  rustPlatform,
  which,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rbspy";
  version = "0.49.0";

  src = fetchFromGitHub {
    owner = "rbspy";
    repo = "rbspy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H4SFivaMmRvAhJy5n/QZ1dHFRfYywrpABMl1A9waYzo=";
  };

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isDarwin rustPlatform.bindgenHook;
  cargoHash = "sha256-NtUJxQTRmXsI76DjJ43UfBf9FskFk/gehw5STcuQEuQ=";
  doCheck = true;

  nativeCheckInputs = [
    ruby
    which
  ];

  # The current implementation of rbspy fails to detect the version of ruby
  # from nixpkgs during tests.
  preCheck = ''
    substituteInPlace src/core/process.rs \
      --replace-fail "/usr/bin/which" "${lib.getExe which}"
    substituteInPlace src/sampler/mod.rs \
      --replace-fail "/usr/bin/which" "${lib.getExe which}"
    substituteInPlace src/core/ruby_spy.rs \
      --replace-fail "/usr/bin/ruby" "${lib.getExe ruby}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sampling CPU Profiler for Ruby";
    homepage = "https://rbspy.github.io/";
    changelog = "https://github.com/rbspy/rbspy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ viraptor ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "rbspy";
  };
})
