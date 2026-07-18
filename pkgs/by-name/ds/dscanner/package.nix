{
  lib,
  fetchFromGitHub,
  buildDubPackage,
  versionCheckHook,
}:

buildDubPackage rec {
  pname = "dscanner";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "dlang-community";
    repo = "D-Scanner";
    tag = "v${version}";
    hash = "sha256-7lZhYlK07VWpSRnzawJ2RL69/U/AH/qPyQY4VfbnVn4=";
  };

  patches = [
    ./fix_version.patch
  ];

  preBuild = ''
    mkdir -p bin/
    echo "v${version}" > bin/dubhash.txt
  '';

  doCheck = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/dscanner -t $out/bin
    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dubLock = ./dub-lock.json;

  meta = {
    description = "Swiss-army knife for D source code";
    homepage = "https://github.com/dlang-community/D-Scanner";
    changelog = "https://github.com/dlang-community/D-Scanner/releases/tag/v${version}";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ ipsavitsky ];
    mainProgram = "dscanner";
  };
}
