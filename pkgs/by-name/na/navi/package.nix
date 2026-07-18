{
  lib,
  stdenv,
  fetchFromGitHub,
  fzf,
  libiconv,
  makeWrapper,
  nix-update-script,
  rustPlatform,
  wget,
  withFzf ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "navi";
  version = "2.24.0";

  src = fetchFromGitHub {
    owner = "denisidoro";
    repo = "navi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zvqxVu147u/m/4B3fhbuQ46txGMrlgQv9d4GGiR8SoQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  cargoHash = "sha256-tQCm8KMVWo6KiKVOMDitHtDXwYGM7INXcT+7fEEiIiI=";

  checkFlags = [
    # error: Found argument '--test-threads' which wasn't expected, or isn't valid in this context
    "--skip=test_parse_variable_line"
  ];

  postInstall = ''
    wrapProgram $out/bin/navi \
      --prefix PATH : "$out/bin" \
      --prefix PATH : ${lib.makeBinPath ([ wget ] ++ lib.optionals withFzf [ fzf ])}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Interactive cheatsheet tool for the command-line and application launchers";
    homepage = "https://github.com/denisidoro/navi";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cust0dian ];
    platforms = lib.platforms.unix;
    mainProgram = "navi";
  };
})
