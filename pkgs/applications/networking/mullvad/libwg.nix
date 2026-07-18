{
  lib,
  buildGoModule,
  mullvad,
}:
buildGoModule {
  inherit (mullvad)
    version
    src
    ;

  pname = "libwg";
  vendorHash = "sha256-uzPtA9RBP5m8+18YBq+SEsgytDOWFCGPzucCzISSiLQ=";

  postInstall = ''
    mv $out/lib/libwg{,.a}
  '';

  # XXX: hack to make the ar archive go to the correct place
  # This is necessary because passing `-o ...` to `ldflags` does not work
  # (this doesn't get communicated everywhere in the chain, apparently, so
  # `go` complains that it can't find an `a.out` file).
  GOBIN = "${placeholder "out"}/lib";

  ldflags = [
    "-s"
    "-w"
    "-buildmode=c-archive"
  ];

  modRoot = "wireguard-go-rs/libwg";
  proxyVendor = true;
  subPackages = [ "." ];
  tags = [ "daita" ];

  meta = {
    description = "Tiny wrapper around wireguard-go";
    homepage = "https://github.com/mullvad/mullvadvpn-app/tree/main/wireguard-go-rs/libwg";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ cole-h ];
  };
}
