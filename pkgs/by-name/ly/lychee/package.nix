{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cacert,
  callPackage,
  installShellFiles,
  rustPlatform,
  testers,
}:

let
  canRun = stdenv.hostPlatform.emulatorAvailable buildPackages;
  lychee = "${stdenv.hostPlatform.emulator buildPackages} $out/bin/lychee${stdenv.hostPlatform.extensions.executable}";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lychee";
  version = "0.24.2";

  src = fetchFromGitHub {
    owner = "lycheeverse";
    repo = "lychee";
    tag = "lychee-v${finalAttrs.version}";
    hash = "sha256-fXuLeLwrE/CINQKqk87o0Dp+8nGOqCyUkS5gTr9YOXY=";
    leaveDotGit = true;

    postFetch = ''
      GIT_DATE=$(git -C $out/.git show -s --format=%cs)
      substituteInPlace $out/lychee-bin/build.rs \
        --replace-fail \
          '("cargo:rustc-env=GIT_DATE={}", git_date())' \
          '("cargo:rustc-env=GIT_DATE={}", "'$GIT_DATE'")'
      rm -rf $out/.git
    '';
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-21J6eH2xSLK2VWnsrMk9WaKjPJiNP2UQGJuYkZUqsnM=";
  nativeCheckInputs = [ cacert ];

  checkFlags = [
    #  Network errors for all of these tests
    # "error reading DNS system conf: No such file or directory (os error 2)" } }
    "--skip=archive::wayback::tests::wayback_suggestion_real_unknown"
    "--skip=archive::wayback::tests::wayback_api_no_breaking_changes"
    "--skip=cli::test_dont_dump_data_uris_by_default"
    "--skip=cli::test_dump_data_uris_in_verbose_mode"
    "--skip=cli::test_exclude_example_domains"
    "--skip=cli::test_local_dir"
    "--skip=cli::test_local_file"
    "--skip=client::tests"
    "--skip=collector::tests"
    "--skip=commands::generate::tests::test_examples_work"
    "--skip=src/lib.rs"
    # Color error for those tests as we are not in a tty
    "--skip=formatters::response::color::tests::test_format_response_with_error_status"
    "--skip=formatters::response::color::tests::test_format_response_with_ok_status"
  ];

  postFixup = lib.optionalString canRun ''
    ${lychee} --generate man > lychee.1
    installManPage lychee.1

    installShellCompletion --cmd lychee \
      --bash <(${lychee} --generate complete-bash) \
      --fish <(${lychee} --generate complete-fish) \
      --zsh <(${lychee} --generate complete-zsh)
  '';

  cargoTestFlags = [
    # don't run doctests since they tend to use the network
    "--lib"
    "--bins"
    "--tests"
  ];

  passthru.tests = {
    fail = callPackage ./tests/fail.nix { };
    fail-emptyDirectory = callPackage ./tests/fail-emptyDirectory.nix { };
    fail-rootRelative = callPackage ./tests/fail-rootRelative.nix { };
    network = testers.runNixOSTest ./tests/network.nix;
    # NOTE: These assume that testers.lycheeLinkCheck uses this exact derivation.
    #       Which is true most of the time, but not necessarily after overriding.
    ok = callPackage ./tests/ok.nix { };
  };

  meta = {
    description = "Fast, async, stream-based link checker written in Rust";
    homepage = "https://github.com/lycheeverse/lychee";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      totoroot
      tuxinaut
    ];

    mainProgram = "lychee";
    downloadPage = "https://github.com/lycheeverse/lychee/releases/tag/lychee-v${finalAttrs.version}";
  };
})
