{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "dnscrypt-proxy";
  version = "2.1.15";

  src = fetchFromGitHub {
    owner = "DNSCrypt";
    repo = "dnscrypt-proxy";
    rev = finalAttrs.version;
    hash = "sha256-o6XZR3w1LfyCGOcF6Gzp39neMp5QjbTxQdL8A81AakM=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-qsbKcgeB/g388TERH8nYy/kfMSN5a21fbUoa80ZMgW4=";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/dnscrypt-proxy/-/raw/main/0001-Make-configuration-file-hierarchy-compliant.patch";
    })
  ];

  vendorHash = null;
  doCheck = false;

  postInstall = ''
    mkdir -p $out/etc/dnscrypt-proxy
    cp dnscrypt-proxy/example-dnscrypt-proxy.toml $out/etc/dnscrypt-proxy/dnscrypt-proxy.toml
  '';

  passthru.tests = { inherit (nixosTests) dnscrypt-proxy; };

  meta = {
    description = "Tool that provides secure DNS resolution";
    homepage = "https://dnscrypt.info/";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      atemu
      waynr
    ];

    platforms = with lib.platforms; unix;
    mainProgram = "dnscrypt-proxy";
  };
})
