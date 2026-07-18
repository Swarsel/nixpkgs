{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  fetchpatch,
  findutils,
  gitMinimal,
  gnused,
  gradle,
  jre,
  makeBinaryWrapper,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "structurizr-cli";
  version = "2025.05.28";

  src = fetchFromGitHub {
    owner = "structurizr";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bypCW7fEfSzVQHhb7wzxQUkXnoDb8QHUsPCpHV7pW/w=";
  };

  patches =
    let
      # Use `gradle-application-plugin` to generate scripts and dist zip instead of in-house launch script
      # PR at https://github.com/structurizr/cli/pull/175
      commits = [
        # Use `gradle-application-plugin`
        {
          hash = "sha256-B1vqQNHHSOgiRysc5ZkcBB/8YZ1dMjJuFu5uwGRQKWs=";
          rev = "eb1657c2be62fb493adde954330a70eebd72026a";
        }
        # Set JDK target correctly
        {
          hash = "sha256-tj7fNOqKLPvgTYKCRIJlGg1OGyGOmmx0Pj4H8oDPVdU=";
          rev = "24be5eeec893df5261100913c4e51ca0bd100689";
        }
        # Remove unused `git.commit` property
        {
          hash = "sha256-wswvXJujyPpbvXvL2SOFC4zZLnfskYFdHvzry66vukQ=";
          rev = "2cb1d86c59f210ce32211395570e8dccf138df16";
        }
        # Set build data correctly
        {
          hash = "sha256-0zUmg+smxQLZm9wWu3JL1pIXQJcQ1uyQ433C1pDLatQ=";
          rev = "3260d8622a9cf6197d6ab5d9440087dcaac3fbb9";
        }
        # Wrap compatibility into java block
        {
          hash = "sha256-Myj3s7Kc+bQS3iJIZoEyc39pn3DkBOHFu/B9UUPKXf8=";
          rev = "1a11940d089a8d70d6e298660c6f5db638cc8d00";
        }
      ];
    in
    map (
      entry:
      fetchpatch {
        hash = entry.hash;
        url = "https://github.com/structurizr/cli/commit/${entry.rev}.patch";
      }
    ) commits;

  postPatch = ''
    substituteInPlace src/main/resources/build.properties \
      --subst-var-by BUILD_NUMBER "${finalAttrs.version}" \
      --subst-var-by BUILD_DATE "1970-01-01T00:00:00Z"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gradle
    makeBinaryWrapper
    gitMinimal
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cp -r build/install/structurizr-cli $out/lib/structurizr-cli

    makeBinaryWrapper $out/lib/structurizr-cli/bin/structurizr-cli $out/bin/structurizr-cli \
      --prefix PATH : "${
        lib.makeBinPath [
          coreutils
          findutils
          gnused
          jre
        ]
      }"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  gradleBuildTask = "installDist";

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  versionCheckProgramArg = "version";

  meta = {
    description = "Structurizr CLI for publishing C4 architecture diagrams and models";
    homepage = "https://github.com/structurizr/cli";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ mhemeryck ];
    platforms = lib.platforms.all;
    mainProgram = "structurizr-cli";
  };
})
