# Trading Analyzer Skill - Complete Guide

## Overview

The Trading Analyzer skill provides intelligent multi-source market analysis, automatically routing between:

- **Cryptocurrency**: TradingView MCP (technical analysis, volume, candle patterns)
- **Stocks**: Alpha Vantage + Yahoo Finance MCPs (fundamentals, news, earnings)

Consolidates data from multiple sources into unified, actionable trading reports.

## Quick Start

### 1. Configuration

Add MCP servers to `.vscode/mcp.json`:

```json
{
  "servers": {
    "tradingview-mcp": {
      "command": "uv",
      "args": [
        "tool",
        "run",
        "--from",
        "git+https://github.com/atilaahmettaner/tradingview-mcp.git",
        "tradingview-mcp"
      ]
    },
    "alphavantage": {
      "command": "uvx",
      "args": ["av-mcp", "YOUR_API_KEY"]
    },
    "yahoo-finance-server": {
      "command": "uvx",
      "args": ["yahoo-finance-server"]
    }
  }
}
```

### 2. Install Dependencies

```bash
pip3 install requests pandas
```

### 3. Run Analysis

```bash
# Crypto analysis
python3 analyze.py BTCUSDT --exchange BINANCE --timeframe 4h

# Stock analysis
python3 analyze.py AAPL --output markdown

# JSON output
python3 analyze.py TSLA --output json
```

## Architecture

### Asset Detection

Automatically identifies symbol type:

```
CRYPTO: Ends with USDT/USDC/BTC/ETH/BNB OR common pairs (BTC, ETH, SOL, etc.)
STOCK:  1-5 letter uppercase tickers (AAPL, MSFT, TSLA)
```

### Data Flow

```
User Input (symbol)
    ↓
[Asset Detector] → Determine type (crypto/stock)
    ↓
    ├─→ [Crypto Analyzer]
    │    ├─ coin_analysis (TradingView)
    │    ├─ smart_volume_scanner
    │    └─ technical indicators
    │
    └─→ [Stock Analyzer]
         ├─ get-ticker-info (Alpha Vantage)
         ├─ get-ticker-news (Yahoo Finance)
         └─ ticker-earning
    ↓
[Report Generator]
    ├─ Markdown (formatted report)
    └─ JSON (raw data)
```

## Crypto Analysis Features

### Available TradingView Tools

| Tool                       | Use Case                                                   |
| -------------------------- | ---------------------------------------------------------- |
| `coin_analysis`            | Detailed technical indicators (RSI, MACD, Bollinger Bands) |
| `smart_volume_scanner`     | Volume + RSI + price change combination                    |
| `volume_breakout_scanner`  | Identify coins with volume spikes                          |
| `top_gainers`              | Best performing coins by timeframe                         |
| `top_losers`               | Worst performing coins                                     |
| `advanced_candle_pattern`  | Progressive candle size increases                          |
| `consecutive_candles_scan` | Bullish/bearish candle sequences                           |

### Example Report (Crypto)

```
# Trading Analysis Report: BTCUSDT

Generated: 2026-02-10T17:30:00Z
Asset Type: CRYPTO

## Price Overview

Current: $45,200.00 (-2.3%) | 24h High: $46,100.00 | Low: $44,800.00
Volume: $28.5B

## Technical Analysis

Trend: **Bearish** | RSI: 35 (Oversold) | MACD: Negative

Bollinger Bands: Below MA | Support: $44,200.00 | Resistance: $46,500.00

## Market Sentiment

**Neutral-Bearish**

## Recommendation

Signal: **HOLD**
Risk Level: Moderate
```

## Stock Analysis Features

### Available Alpha Vantage & Yahoo Finance Tools

| Tool              | Data                                          |
| ----------------- | --------------------------------------------- |
| `get-ticker-info` | P/E ratio, market cap, dividend, fundamentals |
| `get-ticker-news` | Latest headlines with sentiment               |
| `ticker-earning`  | EPS, earnings dates                           |

### Example Report (Stock)

```
# Trading Analysis Report: AAPL

Generated: 2026-02-10T17:30:00Z
Asset Type: STOCK

## Price Overview

Current: $278.12 (+0.80%) | Open: $277.12 | Volume: 50,453,414

## Fundamentals

P/E Ratio: 28.5 | Market Cap: $2.8T | Dividend: 0.92%
Revenue Growth: 2.3% | Profit Margin: 28.1%

## Latest News

1. **Apple announces new AI features** - CNBC (2h ago) [Positive]
2. **Q1 earnings beat estimates** - Reuters (1d ago) [Positive]

## Market Sentiment

**Bullish**

## Recommendation

Signal: **BUY**
Target: $295.00
Risk Level: Low
```

## Usage Examples

### Example 1: Quick Crypto Check

```bash
python3 analyze.py ETHUSDT
```

Provides instant technical overview with RSI, MACD, trend, and recommendation.

### Example 2: Stock Deep Dive

```bash
python3 analyze.py MSFT --output json
```

Returns complete fundamental data, news sentiment, and earnings outlook in structured JSON.

### Example 3: Specific Timeframe

```bash
python3 analyze.py SOLUSDT --timeframe 1h --exchange KUCOIN
```

Analyzes SOL on KUCOIN exchange at 1-hour intervals for short-term trading signals.

### Example 4: Market Screening

For market-wide opportunities, use screener tools:

```python
# Find top gainers (built into example.py)
smart_volume_scanner(exchange="BINANCE", min_volume_ratio=2.0)

# Find candle patterns
advanced_candle_pattern(exchange="KUCOIN", pattern_length=3)
```

## File Structure

```
trading-analyzer/
├── SKILL.md           # Official skill documentation
├── README.md          # This file
├── analyze.py         # Main analyzer script
├── examples.py        # Usage examples
├── _meta.json         # Skill metadata
└── analyzers/         # (Future) Modular analyzer components
    ├── crypto.py
    ├── stock.py
    └── reporters.py
```

## API Integration

### TradingView MCP

Provides crypto-specific analysis:

- Real-time price and volume data
- Technical indicators (RSI, MACD, Bollinger Bands)
- Candle pattern detection
- Market screening

### Alpha Vantage MCP

Provides stock fundamentals:

- Company metrics (P/E, market cap, dividend)
- Financial ratios
- Earnings data
- Daily OHLCV (Open, High, Low, Close, Volume)

### Yahoo Finance MCP

Provides market intelligence:

- News articles with sentiment
- Sector analysis
- Top performers by category
- Real-time quotes

## Error Handling

The analyzer gracefully handles:

- **Missing data sources**: Returns partial report with available data
- **API rate limits**: Caches recent queries (5-minute window)
- **Invalid symbols**: Detects and reports unknown assets
- **Network errors**: Clear error messages with retry guidance

## Performance

- Typical analysis: 2-5 seconds per asset
- Parallel multi-source fetching
- Automatic caching for repeated queries
- Lightweight JSON responses

## Extension Points

### Add New Analyzer

1. Create `analyzers/custom_source.py`
2. Implement `analyze(symbol, options)` method
3. Register in `AssetDetector.detect()` routing logic

### Custom Report Format

1. Extend `ReportGenerator` class
2. Add new format method (e.g., `html_report()`)
3. Update CLI `--output` options

### Additional Data Sources

Edit `analyze.py` to integrate:

- CoinGecko API for altcoin data
- Binance API for real-time quotes
- IEX Cloud for stock alternatives
- Custom sentiment analysis APIs

## Troubleshooting

### MCP Servers Not Responding

```bash
# Verify configuration
cat .vscode/mcp.json

# Check server status (in VS Code terminal)
# Run simple query to each MCP server
```

### API Key Errors

```bash
# For Alpha Vantage
export VANTAGE_API_KEY=your_key_here

# For custom servers, follow their documentation
```

### Symbol Not Recognized

- Check symbol spelling and format
- For crypto: add exchange suffix (BTCUSDT vs BTC)
- For stocks: use standard ticker (AAPL not APPLE)

## Best Practices

1. **Check sentiment before trading**: Use news analysis from Yahoo Finance
2. **Confirm on multiple timeframes**: Check 15m, 1h, 4h, 1D for consonance
3. **Verify volume**: High volume confirms technical signals
4. **Risk management**: Always respect support/resistance levels
5. **Stay informed**: Review latest news and earnings data

## Testing

Run examples to verify setup:

```bash
python3 examples.py
```

This outputs conceptual MCP calls without requiring live servers.

## Performance Optimization

- Cache ticker lookups (symbol → type)
- Batch multiple symbols in single request
- Reuse MCP server connections
- Store recent analyses locally

## Security

- All API keys stored in environment variables
- No credentials in code or config files
- Sandboxed data source access
- Rate-limited API calls

## License

MIT

## Support

For issues or feature requests:

1. Check SKILL.md for official documentation
2. Review examples.py for usage patterns
3. Inspect error messages and logs
4. Verify MCP server configuration

---

**Version**: 2.0.0  
**Last Updated**: February 2026  
**Maintained by**: OpenClaw Skills Team
