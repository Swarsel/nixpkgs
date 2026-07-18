{
  apiGoVendorHook,
  authentik,
  buildGoModule,
  vendorHash,
}:

buildGoModule {
  inherit (authentik) version src;
  inherit vendorHash;
  pname = "authentik-ldap-outpost";
  nativeBuildInputs = [ apiGoVendorHook ];
  env.CGO_ENABLED = 0;
  subPackages = [ "cmd/ldap" ];

  meta = authentik.meta // {
    description = "Authentik ldap outpost. Needed for the external ldap API";
    homepage = "https://goauthentik.io/docs/providers/ldap/";
    mainProgram = "ldap";
  };
}
