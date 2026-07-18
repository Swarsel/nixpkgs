{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
buildGoModule (finalAttrs: {
  pname = "apache-answer";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "answer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QTm/6srSn4oF78795ADpW10bZmyEmqTNezB6JSkS2I4=";
  };

  vendorHash = "sha256-ZZ+6OS967qtstMxdBzDxTU2wvyieZJM+/g9V96rXPVI=";

  preBuild = ''
    cp -r ${finalAttrs.webui}/* ui/build/
  '';

  doCheck = false; # TODO checks are currently broken upstream

  ldflags = [
    "-X main.Version=${finalAttrs.version}"
    "-X main.Commit=${finalAttrs.version}"
  ];

  webui = stdenv.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "apache-answer" + "-webui";

    nativeBuildInputs = [
      pnpmConfigHook
      pnpm
      nodejs
    ];

    buildPhase = ''
      runHook preBuild

      pnpm build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r build/* $out

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) src version pname;
      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-0Jqe0wig28Vb9y0/tZHDfE49MehNR7kJTpChz616tzU=";
      sourceRoot = "${finalAttrs.src.name}/ui";
    };

    sourceRoot = "${finalAttrs.src.name}/ui";
  };

  meta = {
    description = "Q&A platform software for teams at any scales";
    homepage = "https://answer.apache.org/";
    changelog = "https://github.com/apache/answer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      bot-wxt1221
    ];

    platforms = lib.platforms.unix;
    mainProgram = "answer";
  };
})
