{
  stdenv,
  kvrocks,
  valkey,
}:

stdenv.mkDerivation {
  doCheck = true;

  nativeCheckInputs = [
    valkey
    kvrocks.hook
  ];

  preCheck = ''
    kvrocksTestPort=6380
    KVROCKS_SOCKET=/tmp/customkvrocks.sock
  '';

  checkPhase = ''
    runHook preCheck

    echo "running test"
    if redis-cli --scan -p $kvrocksTestPort; then
      echo "connected to kvrocks via localhost"
      PORT_TEST_RAN=1
    fi

    if redis-cli --scan -s $KVROCKS_SOCKET; then
      echo "connected to kvrocks via domain socket"
      SOCKET_TEST_RAN=1
    fi

    runHook postCheck
  '';

  installPhase = ''
    [[ $PORT_TEST_RAN == 1 && $SOCKET_TEST_RAN == 1 ]]
    echo "test passed"
    touch $out
  '';

  __darwinAllowLocalNetworking = true;
  dontUnpack = true;
  name = "kvrocks-test-hook-test";
}
