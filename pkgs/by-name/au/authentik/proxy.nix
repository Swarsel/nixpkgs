{
  apiGoVendorHook,
  authentik,
  buildGoModule,
  vendorHash,
}:

buildGoModule {
  inherit (authentik) version src;
  inherit vendorHash;
  pname = "authentik-proxy-outpost";
  nativeBuildInputs = [ apiGoVendorHook ];
  env.CGO_ENABLED = 0;
  subPackages = [ "cmd/proxy" ];

  meta = authentik.meta // {
    description = "Authentik proxy outpost which is used for HTTP reverse proxy authentication";
    homepage = "https://goauthentik.io/docs/providers/proxy/";
    mainProgram = "proxy";
  };
}
