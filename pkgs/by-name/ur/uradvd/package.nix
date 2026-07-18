{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  uradvd,
  versionCheckHook,
}:

stdenv.mkDerivation {
  pname = "uradvd";
  version = "r26-1e64364d";

  src = fetchFromGitHub {
    owner = "freifunk-gluon";
    repo = "uradvd";
    rev = "1e64364d323acb8c71285a6fb85d384334e7007d";
    hash = "sha256-+MDhBuCPJ/dcKw4/z4PnXXGoNomIz/0QI32XfLR6fK0=";
    deepClone = true;
  };

  nativeBuildInputs = [
    gitMinimal
  ];

  installPhase = ''
    runHook preInstall

    install -D --mode=0755 uradvd -t "$out/bin"

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Tiny IPv6 Router Advertisement Daemon";
    homepage = "https://github.com/freifunk-gluon/uradvd";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ aiyion ];
    platforms = lib.platforms.linux;
    mainProgram = "uradvd";
  };
}
