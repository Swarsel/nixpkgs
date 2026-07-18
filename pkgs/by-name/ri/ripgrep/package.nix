{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
  pcre2,
  pkg-config,
  rustPlatform,
  writableTmpDirAsHomeHook,
  withPCRE2 ? true,
}:

let
  canRunRg = stdenv.hostPlatform.emulatorAvailable buildPackages;
  rg = "${stdenv.hostPlatform.emulator buildPackages} $out/bin/rg${stdenv.hostPlatform.extensions.executable}";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ripgrep";
  version = "15.1.0";

  src = fetchFromGitHub {
    owner = "BurntSushi";
    repo = "ripgrep";
    tag = finalAttrs.version;
    hash = "sha256-0gjwYMUlXYnmIWQS1SVzF1yQw1lpveRLw5qp049lc3I=";
  };

  nativeBuildInputs = [
    installShellFiles
    writableTmpDirAsHomeHook # required for wine when cross-compiling to Windows
  ]
  ++ lib.optional withPCRE2 pkg-config;

  buildInputs = lib.optional withPCRE2 pcre2;
  cargoHash = "sha256-ry3pLuYNwX776Dpj9IE2+uc7eEa5+sQvdNNeG1eJecs=";
  doInstallCheck = true;

  installCheckPhase = ''
    file="$(mktemp)"
    echo "abc\nbcd\ncde" > "$file"
    ${rg} -N 'bcd' "$file"
    ${rg} -N 'cd' "$file"
  ''
  + lib.optionalString withPCRE2 ''
    echo '(a(aa)aa)' | ${rg} -P '\((a*|(?R))*\)'
  '';

  postFixup = lib.optionalString canRunRg ''
    ${rg} --generate man > rg.1
    installManPage rg.1

    installShellCompletion --cmd rg \
      --bash <(${rg} --generate complete-bash) \
      --fish <(${rg} --generate complete-fish) \
      --zsh <(${rg} --generate complete-zsh)
  '';

  __structuredAttrs = true;
  buildFeatures = lib.optional withPCRE2 "pcre2";

  meta = {
    description = "Utility that combines the usability of The Silver Searcher with the raw speed of grep";
    homepage = "https://github.com/BurntSushi/ripgrep";
    changelog = "https://github.com/BurntSushi/ripgrep/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      unlicense # or
      mit
    ];

    maintainers = with lib.maintainers; [
      globin
      ma27
      zowoq
    ];

    platforms = lib.platforms.all;
    mainProgram = "rg";
  };
})
