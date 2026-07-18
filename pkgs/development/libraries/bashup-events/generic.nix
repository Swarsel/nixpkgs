{
  # general
  lib,
  bash,
  branch,
  keep,
  resholve,
  src,
  # variant-specific
  variant,
  version,
  doCheck ? true,
  doInstallCheck ? true,
  fake ? false,
}:
let
  # extracting this so that it's trivial to test in other shells
  installCheck = shell: ''
    echo "testing bashup.events in ${shell}"
    ${shell} <<'EOF'
    source $out/bin/bashup.events
    neat(){
      echo $0: Hi from event \'test event\'. I can have both $1 and $2 arguments.
      exit 0
    }
    event on "test event" @2 neat curried
    echo event registered
    event emit "test event" runtime
    exit 1 # fail if emitting event didn't exit clean
    EOF
  '';

in
resholve.mkDerivation {
  # should be YYYY-MM-DD
  inherit version;
  inherit src;
  inherit doCheck;
  inherit doInstallCheck;
  # bashup.events doesn't version yet but it has two variants with
  # differing features/performance characteristics:
  # - branch master: a variant for bash 3.2+
  # - branch bash44: a variant for bash 4.4+
  pname = "bashup-events${variant}-unstable";
  nativeCheckInputs = [ bash ];

  checkPhase = ''
    runHook preCheck
    ${bash}/bin/bash -n ./bashup.events
    ${bash}/bin/bash ./bashup.events
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dt $out/bin bashup.events
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ bash ];

  installCheckPhase = ''
    runHook preInstallCheck
    ${installCheck "${bash}/bin/bash"}
    runHook postInstallCheck
  '';

  solutions = {
    events = {
      inherit keep;
      inputs = [ ];
      interpreter = "none";
      scripts = [ "bin/bashup.events" ];
    }
    // lib.optionalAttrs (lib.isAttrs fake) { inherit fake; };
  };

  meta = {
    inherit branch;
    description = "Event listener/callback API for creating extensible bash programs";
    homepage = "https://github.com/bashup/events";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ abathur ];
    platforms = lib.platforms.all;
    mainProgram = "bashup.events";
  };
}
