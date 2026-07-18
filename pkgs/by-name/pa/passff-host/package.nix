{
  lib,
  stdenv,
  fetchFromCodeberg,
  nix-update-script,
  pass,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "passff-host";
  version = "1.2.5";

  src = fetchFromCodeberg {
    owner = "PassFF";
    repo = "passff-host";
    tag = finalAttrs.version;
    hash = "sha256-8EThigW6uD5I4YmZYB2uNqdRzqqAHbULNY1UGA0vfAY=";
  };

  postPatch = ''
    sed -i 's#COMMAND = "pass"#COMMAND = "${pass}/bin/pass"#' src/passff.py
  '';

  buildInputs = [ python3 ];
  makeFlags = [ "VERSION=${finalAttrs.version}" ];

  installPhase = ''
    substituteInPlace bin/${finalAttrs.version}/passff.json \
      --replace PLACEHOLDER $out/share/passff-host/passff.py

    install -Dt $out/share/passff-host \
      bin/${finalAttrs.version}/passff.{py,json}

    nativeMessagingPaths=(
      /lib/mozilla/native-messaging-hosts
      /etc/opt/chrome/native-messaging-hosts
      /etc/chromium/native-messaging-hosts
      /etc/vivaldi/native-messaging-hosts
      /lib/librewolf/native-messaging-hosts
    )

    for manifestDir in "''${nativeMessagingPaths[@]}"; do
      install -d $out$manifestDir
      ln -s $out/share/passff-host/passff.json $out$manifestDir/
    done
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Host app for the WebExtension PassFF";
    homepage = "https://codeberg.org/PassFF/passff-host";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
  };
})
