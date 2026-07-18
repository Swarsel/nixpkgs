{
  lib,
  fetchurl,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  sqlite,
  unixodbc,
  zstd,
}:

let
  apexcharts = {
    hash = "sha256-DgRUn+X1cxT0z5O+QcrX48NuVrY1KhoCmHPvVZAvS8k=";
    url = "https://cdn.jsdelivr.net/npm/apexcharts@5.13.0/dist/apexcharts.min.js";
  };
  tablerCss = {
    hash = "sha256-fvdQvRBUamldCxJ2etgEi9jz7F3n2u+xBn+dDao9HJo=";
    url = "https://cdn.jsdelivr.net/npm/@tabler/core@1.4.0/dist/css/tabler.min.css";
  };
  tomSelectCss = {
    hash = "sha256-vW5UjM/Ka9/jIY8I5s5KcudaTRWh/cCGE1ZUsrJvlI0=";
    url = "https://cdn.jsdelivr.net/npm/tom-select@2.6.1/dist/css/tom-select.bootstrap5.css";
  };
  tablerVendorsCss = {
    hash = "sha256-/VPz9GtiH1Es1KGLY706UIayEEgG93B6aIBa3WzwKYc=";
    url = "https://cdn.jsdelivr.net/npm/@tabler/core@1.4.0/dist/css/tabler-vendors.min.css";
  };
  tablerJs = {
    hash = "sha256-tgx2Fg6XYkV027jPEKvmrummSTtgCW/fwV3R3SvZnrk=";
    url = "https://cdn.jsdelivr.net/npm/@tabler/core@1.4.0/dist/js/tabler.min.js";
  };
  tablerIcons = {
    hash = "sha256-aHeH8IGC75mepyW2gj/aYrW7LCEtjobwxvGnVp5j3Uc=";
    url = "https://cdn.jsdelivr.net/npm/@tabler/icons-sprite@3.44.0/dist/tabler-sprite.svg";
  };
  tomselect = {
    hash = "sha256-KmjMBvL4Ni3AYc9OCi9xSEuamESyLEBL4B2gzFrWPGE=";
    url = "https://cdn.jsdelivr.net/npm/tom-select@2.6.1/dist/js/tom-select.popular.min.js";
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sqlpage";
  version = "0.44.1";

  src = fetchFromGitHub {
    owner = "sqlpage";
    repo = "SQLpage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QpengTtKBLJga/LXcN3oPuXDru1zr9Ti/Qpb0tfiEYc=";
  };

  postPatch = ''
    substituteInPlace sqlpage/apexcharts.js \
      --replace-fail '/* !include ${apexcharts.url} */' \
      "$(cat ${fetchurl apexcharts})"
    substituteInPlace sqlpage/sqlpage.css \
      --replace-fail '/* !include ${tablerCss.url} */' \
      "$(cat ${fetchurl tablerCss})" \
      --replace-fail '/* !include ${tablerVendorsCss.url} */' \
      "$(cat ${fetchurl tablerVendorsCss})" \
      --replace-fail '/* !include ${tomSelectCss.url} */' \
      "$(cat ${fetchurl tomSelectCss})"
    substituteInPlace sqlpage/sqlpage.js \
      --replace-fail '/* !include ${tablerJs.url} */' \
      "$(cat ${fetchurl tablerJs})"
    substituteInPlace sqlpage/tabler-icons.svg \
      --replace-fail '/* !include ${tablerIcons.url} */' \
      "$(cat ${fetchurl tablerIcons})"
    substituteInPlace sqlpage/tomselect.js \
      --replace-fail '/* !include ${tomselect.url} */' \
      "$(cat ${fetchurl tomselect})"
    substituteInPlace build.rs \
      --replace-fail "${tablerIcons.url}" "${fetchurl tablerIcons}" \
      --replace-fail "copy_url_to_opened_file(&client, sprite_url, &mut sprite_content).await;" "sprite_content = std::fs::read(sprite_url).unwrap();"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    sqlite
    unixodbc
    zstd
  ];

  cargoHash = "sha256-w4GfkC+sAJRQgo9GEYm4buv+Q8id84wgRSV1WczZUBI=";
  env.ZSTD_SYS_USE_PKG_CONFIG = true;
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "SQL-only webapp builder, empowering data analysts to build websites and applications quickly";
    homepage = "https://github.com/sqlpage/SQLpage";
    changelog = "https://github.com/sqlpage/SQLpage/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hythera ];
    mainProgram = "sqlpage";
  };
})
