{
  lib,
  fetchFromGitHub,
  buildGoModule,
  dbip-country-lite,
  formats,
  go-swag,
  nezha-theme-admin,
  nezha-theme-user,
  nix-update-script,
  nixosTests,
  versionCheckHook,
  withThemes ? [ ],
}:

let
  frontendName = lib.removePrefix "nezha-theme-";

  frontend-templates =
    let
      mkTemplate =
        theme: extra:
        {
          version = theme.version;
          author = theme.src.owner or "";
          is_admin = false;
          is_official = false;
          name = frontendName theme.pname;
          path = "${frontendName theme.pname}-dist";
          repository = theme.meta.homepage or "";
        }
        // extra;

      officialThemes = [
        (mkTemplate nezha-theme-admin {
          is_admin = true;
          is_official = true;
          name = "OfficialAdmin";
        })
        (mkTemplate nezha-theme-user {
          is_official = true;
          name = "Official";
        })
      ];

      communityThemes = map (t: mkTemplate t { }) withThemes;
    in
    (formats.yaml { }).generate "frontend-templates.yaml" (officialThemes ++ communityThemes);
in
buildGoModule (finalAttrs: {
  pname = "nezha";
  version = "2.2.10";

  src = fetchFromGitHub {
    owner = "nezhahq";
    repo = "nezha";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eAJj+R3tSaZNa7aSfwLg8fS9grbGJRoBUBXdQpncqdI=";
  };

  patches = [
    # Nezha originally used ipinfo.mmdb to provide geoip query feature.
    # Unfortunately, ipinfo.mmdb must be downloaded with token.
    # Therefore, we patch the nezha to use dbip-country-lite.mmdb in nixpkgs.
    ./dbip.patch
  ];

  postPatch = ''
    cp ${dbip-country-lite.mmdb} pkg/geoip/geoip.db
  '';

  nativeBuildInputs = [ go-swag ];
  vendorHash = "sha256-rYzkaJqk5r31Uagn1FRFDeICUeK392o1fyP6IBk9zgk=";

  # Generate code for Swagger documentation endpoints (see cmd/dashboard/docs).
  postConfigure = ''
    GOROOT=''${GOROOT-$(go env GOROOT)} swag init --pd -d cmd/dashboard -g main.go -o cmd/dashboard/docs
  '';

  checkFlags = "-skip=^TestSplitDomainSOA$";

  postInstall = ''
    mv $out/bin/dashboard $out/bin/nezha
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true; # TestOptionalAuth_PATWithoutScopeIsDenied

  ldflags = [
    "-s"
    "-X github.com/nezhahq/nezha/service/singleton.Version=${finalAttrs.version}"
  ];

  prePatch =
    let
      allThemes = [
        nezha-theme-admin
        nezha-theme-user
      ]
      ++ withThemes;

      installThemeCmd = theme: "cp -r ${theme} cmd/dashboard/${frontendName theme.pname}-dist";
    in
    ''
      rm -rf cmd/dashboard/*-dist

      cp ${frontend-templates} service/singleton/frontend-templates.yaml
      ${lib.concatMapStringsSep "\n" installThemeCmd allThemes}
    '';

  proxyVendor = true;
  versionCheckProgramArg = "-v";

  passthru = {
    tests = {
      inherit (nixosTests) nezha;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Self-hosted, lightweight server and website monitoring and O&M tool";
    homepage = "https://github.com/nezhahq/nezha";
    changelog = "https://github.com/nezhahq/nezha/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "nezha";
  };
})
