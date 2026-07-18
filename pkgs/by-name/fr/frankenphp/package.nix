{
  lib,
  stdenv,
  fetchFromGitHub,
  brotli,
  buildGoModule,
  cctools,
  darwin,
  libiconv,
  makeBinaryWrapper,
  php,
  pkg-config,
  runCommand,
  versionCheckHook,
  watcher,
  writeText,
}:

let
  phpEmbedWithZts = php.override {
    embedSupport = true;
    staticSupport = stdenv.hostPlatform.isDarwin;
    zendMaxExecutionTimersSupport = stdenv.hostPlatform.isLinux;
    zendSignalsSupport = false;
    ztsSupport = true;
  };
  phpUnwrapped = phpEmbedWithZts.unwrapped;
  phpConfig = "${phpUnwrapped.dev}/bin/php-config";
  pieBuild = stdenv.hostPlatform.isMusl;
in
buildGoModule (finalAttrs: {
  pname = "frankenphp";
  version = "1.12.4";

  src = fetchFromGitHub {
    owner = "php";
    repo = "frankenphp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DzncOAhdDyc5qOipMI8OPss0WciAQIam6GmaUoe8mR8=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    pkg-config
    cctools
    darwin.autoSignDarwinBinariesHook
    libiconv
  ];

  buildInputs = [
    phpUnwrapped
    brotli
    watcher
  ]
  ++ phpUnwrapped.buildInputs;

  vendorHash = "sha256-XY5a8pd5vJ/ouZMASzVqPoeXVfPbnEVDJFKkVNQF+2M=";

  preBuild = ''
    export CGO_CFLAGS="$(${phpConfig} --includes)"
    export CGO_LDFLAGS="-DFRANKENPHP_VERSION=${finalAttrs.version} \
      $(${phpConfig} --ldflags) \
      $(${phpConfig} --libs)"
  '';

  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  preFixup = ''
    mkdir -p $out/lib
    ln -s "${phpEmbedWithZts}/lib/php.ini" "$out/lib/frankenphp.ini"

    wrapProgram $out/bin/frankenphp --set-default PHP_INI_SCAN_DIR $out/lib
  '';

  ldflags = [
    "-s"
    "-w"
    "-X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP ${finalAttrs.version} PHP ${phpUnwrapped.version} Caddy'"
    # pie mode is only available with pkgsMusl, it also automatically add -buildmode=pie to $GOFLAGS
  ]
  ++ (lib.optional pieBuild [ "-static-pie" ]);

  # frankenphp requires C code that would be removed with `go mod tidy`
  # https://github.com/golang/go/issues/26366
  proxyVendor = true;
  sourceRoot = "${finalAttrs.src.name}/caddy";
  subPackages = [ "frankenphp" ];

  tags = [
    "cgo"
    "netgo"
    "ousergo"
    "static_build"
    "nobadger"
    "nomysql"
    "nopgx"
  ];

  versionCheckProgramArg = "version";

  passthru = {
    php = phpEmbedWithZts;

    tests = {
      # TODO: real NixOS test with Symfony application
      phpinfo =
        runCommand "php-cli-phpinfo"
          {
            phpScript = writeText "phpinfo.php" ''
              <?php phpinfo();
            '';
          }
          ''
            ${lib.getExe finalAttrs.finalPackage} php-cli $phpScript > $out
          '';
    };
  };

  meta = {
    description = "Modern PHP app server";
    homepage = "https://github.com/php/frankenphp";
    changelog = "https://github.com/php/frankenphp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.piotrkwiecinski ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "frankenphp";
  };
})
