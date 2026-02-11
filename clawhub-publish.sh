clawdhub login --token $CLAWHUB_TOKEN --no-browser
clawdhub publish --slug drunk-trading-analyzer --version 0.0.3 --name "Trading Analyzer" ./skills/trading-analyzer
#npm run pack-trading