{
  lib,
  stdenv,
  gtk3,
  openssh,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (openssh) src version;
  pname = "openssh-askpass";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk3 ];
  makeFlags = "gnome-ssh-askpass3";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec
    cp -a gnome-ssh-askpass3 $out/libexec/gtk-ssh-askpass
    runHook postInstall
  '';

  dontConfigure = true;
  sourceRoot = "${openssh.pname}-${finalAttrs.version}/contrib";

  meta = {
    description = "A passphrase dialog for OpenSSH and GTK";
    homepage = "https://www.openssh.org";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ n3tshift ];
  };
})
