#!/usr/bin/env python3
"""Unit tests for trading analyzer."""

import pytest
from analyze import AssetDetector, CryptoAnalyzer, StockAnalyzer, ReportGenerator


class TestAssetDetector:
    """Test asset type detection."""
    
    def test_crypto_with_usdt_suffix(self):
        assert AssetDetector.detect('BTCUSDT') == 'crypto'
        assert AssetDetector.detect('ETHUSDT') == 'crypto'
    
    def test_crypto_with_other_suffixes(self):
        assert AssetDetector.detect('BTCUSDC') == 'crypto'
        assert AssetDetector.detect('ETHBTC') == 'crypto'
    
    def test_common_crypto_symbols(self):
        assert AssetDetector.detect('BTC') == 'crypto'
        assert AssetDetector.detect('ETH') == 'crypto'
        assert AssetDetector.detect('SOL') == 'crypto'
    
    def test_stock_symbols(self):
        assert AssetDetector.detect('AAPL') == 'stock'
        assert AssetDetector.detect('GOOGL') == 'stock'
        assert AssetDetector.detect('MSFT') == 'stock'
        assert AssetDetector.detect('TSLA') == 'stock'
    
    def test_case_insensitive(self):
        assert AssetDetector.detect('btcusdt') == 'crypto'
        assert AssetDetector.detect('aapl') == 'stock'


class TestCryptoAnalyzer:
    """Test cryptocurrency analysis."""
    
    def test_analyze_returns_dict(self):
        result = CryptoAnalyzer.analyze('BTCUSDT')
        assert isinstance(result, dict)
    
    def test_analyze_contains_required_fields(self):
        result = CryptoAnalyzer.analyze('BTCUSDT')
        assert 'symbol' in result
        assert 'price_overview' in result
        assert 'technical_analysis' in result
        assert 'recommendation' in result
    
    def test_analyze_custom_exchange(self):
        result = CryptoAnalyzer.analyze('ETHUSDT', exchange='KUCOIN')
        assert result['exchange'] == 'KUCOIN'
    
    def test_analyze_custom_timeframe(self):
        result = CryptoAnalyzer.analyze('BTCUSDT', timeframe='4h')
        assert result['timeframe'] == '4h'


class TestStockAnalyzer:
    """Test stock analysis."""
    
    def test_analyze_returns_dict(self):
        result = StockAnalyzer.analyze('AAPL')
        assert isinstance(result, dict)
    
    def test_analyze_contains_required_fields(self):
        result = StockAnalyzer.analyze('AAPL')
        assert 'symbol' in result
        assert 'price_overview' in result
        assert 'fundamentals' in result
        assert 'latest_news' in result
        assert 'recommendation' in result


class TestReportGenerator:
    """Test report generation."""
    
    def test_markdown_report_crypto(self):
        analysis = CryptoAnalyzer.analyze('BTCUSDT')
        report = ReportGenerator.markdown_report('BTCUSDT', analysis, 'crypto')
        assert isinstance(report, str)
        assert 'BTCUSDT' in report
        assert 'Price Overview' in report
        assert 'Technical Analysis' in report
    
    def test_markdown_report_stock(self):
        analysis = StockAnalyzer.analyze('AAPL')
        report = ReportGenerator.markdown_report('AAPL', analysis, 'stock')
        assert isinstance(report, str)
        assert 'AAPL' in report
        assert 'Price Overview' in report
        assert 'Fundamentals' in report
    
    def test_json_report_crypto(self):
        import json
        analysis = CryptoAnalyzer.analyze('BTCUSDT')
        report = ReportGenerator.json_report('BTCUSDT', analysis, 'crypto')
        data = json.loads(report)
        assert data['symbol'] == 'BTCUSDT'
        assert data['asset_type'] == 'crypto'
    
    def test_json_report_stock(self):
        import json
        analysis = StockAnalyzer.analyze('AAPL')
        report = ReportGenerator.json_report('AAPL', analysis, 'stock')
        data = json.loads(report)
        assert data['symbol'] == 'AAPL'
        assert data['asset_type'] == 'stock'


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
