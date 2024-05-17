{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, nix-update-script
, nixosTests
, testers
, sonic-server
}:

rustPlatform.buildRustPackage rec {
  pname = "sonic-server";
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "valeriansaliou";
    repo = "sonic";
    rev = "refs/tags/v${version}";
    hash = "sha256-kNuLcImowjoptNQI12xHD6Tv+LLYdwlpauqYviKw6Xk=";
  };

  cargoHash = "sha256-9XSRb5RB82L72RzRWPJ45AJahkRnLwAL7lI2QFqbeko=";

  checkFlags = [
    "--skip=store::fst::tests::it_acquires_graph"
    "--skip=store::fst::tests::it_janitors_graph"
    "--skip=store::fst::tests::it_proceeds_primitives"
    "--skip=store::kv::tests::it_acquires_database"
    "--skip=store::kv::tests::it_janitors_database"
    "--skip=store::kv::tests::it_proceeds_actions"
    "--skip=store::kv::tests::it_proceeds_primitives"
  ];

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-faligned-allocation";

  postPatch = ''
    substituteInPlace src/main.rs --replace "./config.cfg" "$out/etc/sonic/config.cfg"
  '';

  postInstall = ''
    install -Dm444 -t $out/etc/sonic config.cfg
    install -Dm444 -t $out/lib/systemd/system debian/sonic.service

    substituteInPlace \
      $out/lib/systemd/system/sonic.service \
      --replace /usr/bin/sonic $out/bin/sonic \
      --replace /etc/sonic.cfg $out/etc/sonic/config.cfg
  '';

  passthru = {
    tests = {
      inherit (nixosTests) sonic-server;
      version = testers.testVersion {
        command = "sonic --version";
        package = sonic-server;
      };
    };
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Fast, lightweight and schema-less search backend";
    homepage = "https://github.com/valeriansaliou/sonic";
    changelog = "https://github.com/valeriansaliou/sonic/releases/tag/v${version}";
    license = licenses.mpl20;
    platforms = platforms.unix;
    mainProgram = "sonic";
    maintainers = with maintainers; [ pleshevskiy anthonyroussel ];
  };
}
