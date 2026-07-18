{
  lib,
  fetchFromGitHub,
  aria2,
  makeWrapper,
  swift,
  swiftPackages,
  swiftpm,
  swiftpm2nix,
}:
let
  generated = swiftpm2nix.helpers ./generated;
  stdenv = swiftPackages.stdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xcodes";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "XcodesOrg";
    repo = "xcodes";
    rev = finalAttrs.version;
    hash = "sha256-eH6AdboJsGQ0iWoRllOMzhjM/1t43DB1U0bOu6J/uo4=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    binPath="$(swiftpmBinPath)"
    install -D $binPath/xcodes $out/bin/xcodes
    wrapProgram $out/bin/xcodes \
      --prefix PATH : ${lib.makeBinPath [ aria2 ]}

    runHook postInstall
  '';

  configurePhase = generated.configure;

  meta = {
    description = "Command-line tool to install and switch between multiple versions of Xcode";
    homepage = "https://github.com/XcodesOrg/xcodes";
    changelog = "https://github.com/XcodesOrg/xcodes/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      # unxip
      lgpl3Only
    ];

    maintainers = with lib.maintainers; [
      _0x120581f
      emilytrau
    ];

    platforms = lib.platforms.darwin;
  };
})
