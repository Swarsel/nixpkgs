{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  installShellFiles,
  nix-update-script,
  scdoc,
  versionCheckHook,
}:

let
  version = "1.0.1";
in

buildGoModule {
  inherit version;
  pname = "mjmap";

  src = fetchFromSourcehut {
    owner = "~rockorager";
    repo = "mjmap";
    rev = "v${version}";
    hash = "sha256-VV+bZ01l+uEe3wqdYyVwpzsZJNzoTCD38F6a58dozbg=";
  };

  nativeBuildInputs = [
    scdoc
    installShellFiles
  ];

  vendorHash = "sha256-sZsS8q/hkA2T/8QmtKzNof0mzCuWYin227+/7k3XTM0=";

  postBuild = ''
    make mjmap.1
  '';

  postInstall = ''
    installManPage mjmap.1
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "mjmap";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sendmail‐compatible JMAP client";
    homepage = "https://git.sr.ht/~rockorager/mjmap";
    license = lib.licenses.mpl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.emily ];
    platforms = lib.platforms.unix;
    mainProgram = "mjmap";
  };
}
