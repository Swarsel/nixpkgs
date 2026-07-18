{
  lib,
  buildRubyGem,
  bundler,
  nix-update-script,
  ruby,
  testers,
  versionCheckHook,
  writeScript,
}:

buildRubyGem rec {
  inherit ruby;
  version = "2.7.2";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup = ''
    substituteInPlace $out/bin/bundle --replace-fail "activate_bin_path" "bin_path"
  '';

  dontPatchShebangs = true;
  gemName = "bundler";
  name = "${gemName}-${version}";
  source.sha256 = "sha256-Heyvni4ay5G2WGopJcjz9tojNKgnMaYv8t7RuDwoOHE=";
  versionCheckProgram = "${placeholder "out"}/bin/bundler";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Manage your Ruby application's gem dependencies";
    homepage = "https://bundler.io";
    changelog = "https://github.com/ruby/rubygems/blob/bundler-v${version}/bundler/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      anthonyroussel
      guylamar2006
    ];

    mainProgram = "bundler";
  };
}
