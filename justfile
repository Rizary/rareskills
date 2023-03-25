set dotenv-load

test_presalenft:
    forge test --match-contract PresaleNFTTest  --match-path test/PresaleNFT.t.sol -vvvvv

test_bondingcurve:
    forge test --match-contract BondingCurveTokenTest  --match-path test/BondingCurveToken.t.sol -vvvvv
    
test_godmode:
    forge test --match-contract GodModeTokenTest  --match-path test/GodModeToken.t.sol -vvvvv

test_all:
    forge test -vvvvv