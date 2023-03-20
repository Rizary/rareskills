set dotenv-load

test_sanctions:
    forge test --match-contract SanctionsTokenTest  --match-path test/SanctionsToken.t.sol -vvvvv

test_bondingcurve:
    forge test --match-contract BondingCurveTokenTest  --match-path test/BondingCurveToken.t.sol -vvvvv
    
test_godmode:
    forge test --match-contract GodModeTokenTest  --match-path test/GodModeToken.t.sol -vvvvv

test_all:
    forge test -vvvvv