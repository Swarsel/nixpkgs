{
  lib,
  stdenv,
  fetchurl,
  libarchive,
  nix-update-script,
  undmg,
  xar,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "karabiner-elements";
  version = "15.7.0";

  src = fetchurl {
    url = "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v${finalAttrs.version}/Karabiner-Elements-${finalAttrs.version}.dmg";
    hash = "sha256-Uy0k4xxkr33j92jxEhD/6DF0hhkdf8acU7lr3hTaFa4=";
  };

  outputs = [
    "out"
    "driver"
  ];

  postPatch = ''
    shopt -s globstar
    for f in *.pkg/Library/**/Launch{Agents,Daemons}/*.plist; do
      substituteInPlace "$f" \
        --replace-fail "/Library/" "$out/Library/"
    done
  '';

  nativeBuildInputs = [
    libarchive
    xar
    undmg
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out $driver
    cp -R Installer.pkg/Applications Installer.pkg/Library $out
    cp -R Karabiner-DriverKit-VirtualHIDDevice.pkg/Applications Karabiner-DriverKit-VirtualHIDDevice.pkg/Library $driver

    cp "$out/Library/Application Support/org.pqrs/Karabiner-Elements/package-version" "$out/Library/Application Support/org.pqrs/Karabiner-Elements/version"
    runHook postInstall
  '';

  dontFixup = true; # notarization breaks if fixup is enabled
  sourceRoot = ".";

  unpackPhase = ''
    undmg $src
    xar -xf Karabiner-Elements.pkg
    cd Installer.pkg
    zcat Payload | bsdcpio -i
    cd ../Karabiner-DriverKit-VirtualHIDDevice.pkg
    zcat Payload | bsdcpio -i
    cd ..
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Powerful utility for keyboard customization on macOS Ventura (13) or later";
    homepage = "https://karabiner-elements.pqrs.org/";
    changelog = "https://github.com/pqrs-org/Karabiner-Elements/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ auscyber ];
    platforms = lib.platforms.darwin;
  };
})
