{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "gotop";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "xxxserxxx";
    repo = "gotop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-W7a3QnSIR95N88RqU2sr6oEDSqOXVfAwacPvS219+1Y=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-KLeVSrPDS1lKsKFemRmgxT6Pxack3X3B/btSCOUSUFY=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  postInstall = ''
    $out/bin/gotop --create-manpage > gotop.1
    installManPage gotop.1
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  proxyVendor = true;

  meta = {
    description = "Terminal based graphical activity monitor inspired by gtop and vtop";
    homepage = "https://github.com/xxxserxxx/gotop";
    changelog = "https://github.com/xxxserxxx/gotop/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.magnetophon ];
    mainProgram = "gotop";
  };
})
