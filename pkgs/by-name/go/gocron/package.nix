{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  buildGoModule,
  fetchYarnDeps,
  makeWrapper,
  nix-update-script,
  nixosTests,
  nodejs,
  versionCheckHook,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

buildGoModule (finalAttrs: {

  pname = "gocron";
  version = "0.9.14";

  src = fetchFromGitHub {
    owner = "flohoss";
    repo = "gocron";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LKjK5V+WrzTJlWPytafy8Ypva41RW4/12aSGaJj572I=";
  };

  postPatch = ''
    substituteInPlace handlers/web.go \
      --replace-fail "web/assets" "${finalAttrs.gocron-web}/assets" \
      --replace-fail "web/static" "${finalAttrs.gocron-web}/static" \
      --replace-fail "web/index.html" "${finalAttrs.gocron-web}/index.html"
    substituteInPlace main.go \
      --replace-fail '"github.com/flohoss/gocron/internal/software"' "" \
      --replace-fail "software.Install()" ""
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  vendorHash = "sha256-VbmS9Fh0pr/dUB+pZBqKbi4bu6Do/3TRr9uI3TmGsOM=";

  postInstall = ''
    wrapProgram $out/bin/gocron --prefix PATH : ${
      lib.makeBinPath [
        bash
      ]
    }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  gocron-web = stdenv.mkDerivation (finalAttrsWebassets: {
    inherit (finalAttrs) version;
    pname = "${finalAttrs.pname}-web";
    src = "${finalAttrs.src}/web";

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      yarnInstallHook
      nodejs
    ];

    preBuild = ''
      yarn types
    '';

    postBuild = ''
      mv dist/ $out
    '';

    yarnOfflineCache = fetchYarnDeps {
      hash = "sha256-f0xnF9gd3c0KPrORPVkApyWPy+DazyzHeQu32wWybiw=";
      yarnLock = finalAttrsWebassets.src + "/yarn.lock";
    };

  });

  ldflags = [
    "-s"
    "-w"
    "-X github.com/flohoss/gocron/internal/buildinfo.Version=${finalAttrs.version}"
  ];

  passthru.tests = nixosTests.gocron;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "gocron-web"
    ];
  };

  meta = {
    description = "Task scheduler built with Go and Vue.js.";
    homepage = "https://github.com/flohoss/gocron";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      juliusfreudenberger
    ];

    mainProgram = "gocron";
  };

})
