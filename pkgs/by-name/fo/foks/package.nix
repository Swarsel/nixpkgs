{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  foks, # self
  pcsclite,
  pkg-config,
  versionCheckHook,
  server ? false,
}:
let
  client = !server;
  pname = if server then "foks-server" else "foks";
  subPackages = if server then [ "server/foks-server" ] else [ "client/foks" ];
in
buildGoModule (finalAttrs: {
  inherit pname;
  inherit subPackages;
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "foks-proj";
    repo = "go-foks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JY0ec+LNRQf0S8gTeazvQhvQ7LRM3zz1qvopGPaKM1k=";
  };

  postPatch = ''
    cd ./server/web/templates
    templ generate
    cd -
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    finalAttrs.passthru.templ
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pcsclite ];
  vendorHash = "sha256-W0lyLy7k3xin8VSdxNgeh1FpHprOKIDduHIW3Oqk1LY=";

  postInstall = lib.optionalString client ''
    ln -s $out/bin/{foks,git-remote-foks}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  excludedPackages = [ "server" ];
  versionCheckProgramArg = "version";

  passthru = {
    server = foks.override { server = true; };

    templ = buildPackages.templ.overrideAttrs (old: {
      pname = "templ-foks";
      version = "0.3.833";

      src = old.src.override {
        hash = "sha256-4K1MpsM3OuamXRYOllDsxxgpMRseFGviC4RJzNA7Cu8=";
      };

      vendorHash = "sha256-OPADot7Lkn9IBjFCfbrqs3es3F6QnWNjSOHxONjG4MM=";
    });
  };

  meta = {
    description = "Federated key management and distribution system";
    homepage = "https://foks.pub";
    changelog = "https://github.com/foks-proj/go-foks/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      poptart
      phanirithvij
    ];

    mainProgram = pname;
    downloadPage = "https://github.com/foks-proj/go-foks";
  };
})
