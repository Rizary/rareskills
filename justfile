set dotenv-load

test_presalenft:
    forge test --match-contract PresaleNFTTest  --match-path test/PresaleNFT.t.sol -vvvvv

test_primenft:
    forge test --match-contract PrimeNFTTest  --match-path test/PrimeNFT.t.sol -vvvvv

test_stakingmanager:
    forge test --match-contract StakingManagerTest  --match-path test/StakingManager.t.sol -vvvvv
    
test_stakingtoken:
    forge test --match-contract StakingTokenTest  --match-path test/StakingToken.t.sol -vvvvv

test_all:
    forge test -vvvvv