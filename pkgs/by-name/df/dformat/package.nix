{
  lib,
  fetchFromGitHub,
  buildDubPackage,
  versionCheckHook,
}:

buildDubPackage rec {
  pname = "dfmt";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "dlang-community";
    repo = "dfmt";
    tag = "v${version}";
    hash = "sha256-QjmYPIQFs+91jB1sdaFoenfWt5TLXyEJauSSHP2fd+M=";
  };

  patches = [
    # do not run the dubhash tool, we supply the version in preBuild
    ./fix_version.patch
  ];

  preBuild = ''
    mkdir -p bin/
    echo "v${version}" > bin/dubhash.txt
  '';

  doCheck = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/dfmt -t $out/bin
    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dubLock = ./dub-lock.json;

  meta = {
    description = "Formatter for D source code";
    homepage = "https://github.com/dlang-community/dfmt";
    changelog = "https://github.com/dlang-community/dfmt/releases/tag/v${version}";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ ipsavitsky ];
    mainProgram = "dfmt";
  };
}
