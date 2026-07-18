{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  dart-sass,
  fetchPnpmDeps,
  mage,
  nixosTests,
  nodejs_24,
  pnpmConfigHook,
  pnpm_10,
  writeShellScriptBin,
}:

let
  version = "2.3.0";
  src = fetchFromGitHub {
    owner = "go-vikunja";
    repo = "vikunja";
    rev = "v${version}";
    hash = "sha256-bdHiSFaN0vNQMhy6GPlpoFeYrk2CLvO7E30d8J/9GC0=";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    inherit version src;
    pname = "vikunja-frontend";

    postPatch = ''
      substituteInPlace src/version.json \
        --replace-fail '"dev"' '"${finalAttrs.version}"'
    '';

    nativeBuildInputs = [
      nodejs_24
      dart-sass
      pnpmConfigHook
      pnpm_10
    ];

    postBuild = ''
      # Force sass-embedded to use our dart-sass instead of bundled binaries.
      substituteInPlace node_modules/sass-embedded/dist/lib/src/compiler-path.js \
        --replace-fail 'compilerCommand = (() => {' 'compilerCommand = (() => { return ["${lib.getExe dart-sass}"];'
      pnpm run build
    '';

    doCheck = true;

    checkPhase = ''
      pnpm run test:unit --run
    '';

    installPhase = ''
      cp -r dist/ $out
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;

      fetcherVersion = 3;
      hash = "sha256-cDGeIrCxZtcomu3YxikutjXpVe3EeUZ/L3+3y9yx67s=";
      pnpm = pnpm_10;
    };

    sourceRoot = "${finalAttrs.src.name}/frontend";
  });

  # Injects a `t.Skip()` into a given test since there's apparently no other way to skip tests here.
  skipTest =
    lineOffset: testCase: file:
    let
      jumpAndAppend = lib.concatStringsSep ";" (lib.replicate (lineOffset - 1) "n" ++ [ "a" ]);
    in
    ''
      sed -i -e '/${testCase}/{
      ${jumpAndAppend} t.Skip();
      }' ${file}
    '';
in
buildGoModule {
  inherit src version;
  inherit frontend;
  pname = "vikunja";

  nativeBuildInputs =
    let
      fakeGit = writeShellScriptBin "git" ''
        if [[ $@ = "describe --tags --always --abbrev=10" ]]; then
            echo "${version}"
        else
            >&2 echo "Unknown command: $@"
            exit 1
        fi
      '';
    in
    [
      fakeGit
      mage
    ];

  vendorHash = "sha256-4UMnfbwL2JFnw9KZDO5sq6XCSBUD5ejeqp6vaTbYWJc=";

  postConfigure = ''
    # These tests need internet, so we skip them.
    ${skipTest 1 "TestConvertTrelloToVikunja" "pkg/modules/migration/trello/trello_test.go"}
    ${skipTest 1 "TestConvertTodoistToVikunja" "pkg/modules/migration/todoist/todoist_test.go"}
    # These tests require a full config with public URL and CORS enabled.
    ${skipTest 1 "TestCreateOrganizationMap" "pkg/modules/migration/trello/trello_test.go"}
    ${skipTest 1 "TestTaskAttachmentUploadSize" "pkg/webtests/task_attachment_upload_test.go"}
  '';

  buildPhase = ''
    runHook preBuild

    # Fixes "mkdir /homeless-shelter: permission denied" - "Error: error compiling magefiles" during build
    export HOME=$(mktemp -d)
    mage build:build

    runHook postBuild
  '';

  checkPhase = ''
    mage test:feature
    mage test:web
  '';

  installPhase = ''
    runHook preInstall
    install -Dt $out/bin vikunja
    runHook postInstall
  '';

  prePatch = ''
    cp -r ${frontend} frontend/dist
  '';

  passthru = {
    frontend = frontend;
    tests.vikunja = nixosTests.vikunja;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Todo-app to organize your life";
    homepage = "https://vikunja.io/";
    changelog = "https://github.com/go-vikunja/vikunja/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      leona
      adamcstephens
    ];

    platforms = lib.platforms.linux;
    mainProgram = "vikunja";
  };
}
