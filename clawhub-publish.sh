clawdhub login --token $CLAWHUB_TOKEN --no-browser
clawdhub publish --slug drunk-trading-analyzer --version 0.0.5 --name "Trading Analyzer" ./skills/trading-analyzer
#npm run pack-trading