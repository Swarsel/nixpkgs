{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  installShellFiles,
  makeWrapper,
  nodejs_22,
}:

buildNpmPackage rec {
  pname = "clever-tools";
  version = "4.11.0";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "clever-tools";
    rev = version;
    hash = "sha256-ma1EZL5xuUw8BrECFamSR1I8XJk8PERW7YJSj8JTp4w=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  npmDepsHash = "sha256-9TPH+jRcM161MhabA9m0GcgAzc+yO1a1zh8vQHjZt7g=";

  buildPhase = ''
    runHook preBuild
    node scripts/bundle-cjs.js ${version} false
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/clever-tools
    cp build/${version}/clever.cjs $out/lib/clever-tools/clever.cjs

    makeWrapper ${nodejs}/bin/node $out/bin/clever \
      --add-flags "$out/lib/clever-tools/clever.cjs" \
      --set NO_UPDATE_NOTIFIER true

    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd clever \
      --bash <($out/bin/clever --bash-autocomplete-script $out/bin/clever) \
      --zsh <($out/bin/clever --zsh-autocomplete-script $out/bin/clever)
  '';

  nodejs = nodejs_22;

  meta = {
    description = "Deploy on Clever Cloud and control your applications, add-ons, services from command line";
    homepage = "https://github.com/CleverCloud/clever-tools";
    changelog = "https://github.com/CleverCloud/clever-tools/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.floriansanderscc ];
    mainProgram = "clever";
  };
}
