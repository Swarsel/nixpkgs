{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cctools,
  fetchNpmDeps,
  libtool,
  mailpit,
  nixosTests,
  nodejs,
  npmHooks,
  python3,
  testers,
}:

let
  source = import ./source.nix;

  inherit (source)
    version
    vendorHash
    ;

  src = fetchFromGitHub {
    owner = "axllent";
    repo = "mailpit";
    rev = "v${version}";
    hash = source.hash;
  };

  libtool' = if stdenv.hostPlatform.isDarwin then cctools else libtool;

  # Separate derivation, because if we mix this in buildGoModule, the separate
  # go-modules build inherits specific attributes and fails. Getting that to
  # work is hackier than just splitting the build.
  ui = stdenv.mkDerivation {
    inherit src version;
    pname = "mailpit-ui";

    nativeBuildInputs = [
      nodejs
      python3
      libtool'
      npmHooks.npmConfigHook
    ];

    # error "C++20 or later required." for dependency node_modules/tree-sitter
    env.NIX_CFLAGS_COMPILE = "-std=c++20";

    buildPhase = ''
      npm run package
    '';

    installPhase = ''
      mv server/ui/dist $out
    '';

    npmDeps = fetchNpmDeps {
      inherit src;
      hash = source.npmDepsHash;
    };
  };

in

buildGoModule (finalAttrs: {
  inherit src version vendorHash;
  pname = "mailpit";
  env.CGO_ENABLED = 0;

  preBuild = ''
    cp -r ${finalAttrs.passthru.ui} server/ui/dist
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-X github.com/axllent/mailpit/config.Version=${version}"
  ];

  passthru = {
    inherit ui;

    tests = {
      # cannot use versionCheckHook due to the extra --no-release-check flag
      # for workarounds and other solutions see https://github.com/NixOS/nixpkgs/pull/486143#discussion_r2754533347
      version = testers.testVersion {
        command = "mailpit version --no-release-check";
        package = mailpit;
      };
    }
    // lib.optionalAttrs (!stdenv.hostPlatform.isDarwin) {
      inherit (nixosTests) mailpit;
    };

    updateScript = {
      command = ./update.sh;
      supportedFeatures = [ "commit" ];
    };
  };

  meta = {
    description = "Email and SMTP testing tool with API for developers";
    homepage = "https://mailpit.axllent.org";
    changelog = "https://github.com/axllent/mailpit/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      stephank
      phanirithvij
    ];

    mainProgram = "mailpit";
    downloadPage = "https://github.com/axllent/mailpit";
  };
})
