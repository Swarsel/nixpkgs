{
  stdenv,
  memcachedTestHook,
  netcat,
}:

stdenv.mkDerivation {
  doCheck = true;

  nativeCheckInputs = [
    memcachedTestHook
    netcat
  ];

  preCheck = ''
    memcachedTestPort=11212
  '';

  checkPhase = ''
    runHook preCheck

    echo "running test"
    if echo -e "stats\nquit" | nc localhost $memcachedTestPort; then
      echo "connected to memcached"
      TEST_RAN=1
    fi

    runHook postCheck
  '';

  installPhase = ''
    [[ $TEST_RAN == 1 ]]
    echo "test passed"
    touch $out
  '';

  __darwinAllowLocalNetworking = true;
  dontUnpack = true;
  name = "memcached-test-hook-test";
}
