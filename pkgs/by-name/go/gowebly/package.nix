{
  lib,
  fetchFromGitHub,
  air,
  buildGoModule,
  bun,
  makeWrapper,
  nix-update-script,
  nodejs,
  templ,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "gowebly";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "gowebly";
    repo = "gowebly";
    tag = "v${version}";
    hash = "sha256-/MB8YuqeZUb9P6RPO2sgwtYShaNkEFckiVBtnHRPkc4=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  vendorHash = "sha256-8i1o0Dn4xJ1P3CrYDW0X8epiIpjmIac6gENBYi/bmQo=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    wrapProgram $out/bin/gowebly \
      --prefix PATH : ${
        lib.makeBinPath [
          air
          templ
          bun
          nodejs
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  versionCheckProgramArg = "doctor";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool to create web applications with Go backend";

    longDescription = ''
      A CLI tool that makes it easy to create web applications
      with Go on the backend, using htmx, hyperscript or Alpine.js,
      and the most popular CSS frameworks on the frontend.
    '';

    homepage = "https://gowebly.org";
    changelog = "https://github.com/gowebly/gowebly/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cterence ];
    mainProgram = "gowebly";
  };
}
