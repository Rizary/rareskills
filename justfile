set dotenv-load

test_sanctions:
    forge test --match-path test/SanctionsTokenTest -vvvvv

test_bondingcurve:
    forge test --match-path test/BondingCurveTokenTest -vvvvv
    
test_godmode:
    forge test --match-path test/GodModeTokenTest -vvvvv

test_all:
    forge test -vvvvv