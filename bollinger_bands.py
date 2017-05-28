"""Bollinger Bands."""

import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


def symbol_to_path(symbol, base_dir="data"):
    """Return CSV file path given ticker symbol."""
    return os.path.join(base_dir, "{}.csv".format(str(symbol)))


def get_data(symbols, dates):
    """Read stock data (adjusted close) for given symbols from CSV files."""
    df = pd.DataFrame(index=dates)
    if 'SPY' not in symbols:  # add SPY for reference, if absent
        symbols.insert(0, 'SPY')

    for symbol in symbols:
        df_temp = pd.read_csv(symbol_to_path(symbol), index_col='Date',
                              parse_dates=True, usecols=['Date', 'Adj Close'], na_values=['nan'])
        df_temp = df_temp.rename(columns={'Adj Close': symbol})
        df = df.join(df_temp)
        if symbol == 'SPY':  # drop dates SPY did not trade
            df = df.dropna(subset=["SPY"])

    return df


def plot_data(df, title="Stock prices", xlabel="Date", ylabel="Price"):
    """Plot stock prices with a custom title and meaningful axis labels."""
    ax = df.plot(title=title, fontsize=12)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    plt.show()


def get_rolling_mean(values, window):
    """Return rolling mean of given values, using specified window size."""
    return values.rolling(window=window, center=False).mean()


def get_rolling_std(values, window):
    """Return rolling standard deviation of given values, using specified window size."""
    return values.rolling(window=window, center=False).std()


def get_bollinger_bands(rm, rstd):
    """Return upper and lower Bollinger Bands."""
    upper_band = rm+2*rstd
    lower_band = rm-2*rstd
    return upper_band, lower_band

def compute_daily_returns(df):
    """"Compute and return the daily return values"""
    df2 = df.copy()
    #df2.iloc[1:, :] = df2.iloc[1:, :] / df2.iloc[:-1, :].values - 1
    #df2.iloc[0,:] = 0
    df2 = (df/df.shift(1))-1
    df2.iloc[0, :] = 0
    return df2

def test_run():
    # Read data
    dates = pd.date_range('2012-01-01', '2012-12-31')
    symbols = ['SPY','IBM']
    df = get_data(symbols, dates)

    # Compute Bollinger Bands
    # 1. Compute rolling mean
    rm_SPY = get_rolling_mean(df['SPY'], window=20)

    # 2. Compute rolling standard deviation
    rstd_SPY = get_rolling_std(df['SPY'], window=20)

    # 3. Compute upper and lower bands
    upper_band, lower_band = get_bollinger_bands(rm_SPY, rstd_SPY)

    # Plot raw SPY values, rolling mean and Bollinger Bands
    ax = df['SPY'].plot(title="Bollinger Bands", label='SPY')
    rm_SPY.plot(label='Rolling mean', ax=ax)
    upper_band.plot(label='upper band', ax=ax)
    lower_band.plot(label='lower band', ax=ax)

    # Add axis labels and legend
    ax.set_xlabel("Date")
    ax.set_ylabel("Price")
    ax.legend(loc='upper left')
    plt.show()

def plotHistogram(daily_returns):
    daily_returns['IBM'].hist(bins=20, label='IBM')
    daily_returns['SPY'].hist(bins=20, label='SPY')

    plt.legend(loc='upper right')

    mean = daily_returns.mean()
    print "mean=", mean
    std = daily_returns.std()
    print "std=", std

    # plt.axvline(mean, color="w", linestyle='dashed', linewidth=2)

    # plt.axvline(std, color="r", linestyle='dashed', linewidth=2)
    # plt.axvline(-std, color="r", linestyle='dashed', linewidth=2)

    print daily_returns.kurtosis()

    plt.show()


def test_run_daily_returns():
    # Read data
    dates = pd.date_range('2009-01-01', '2014-07-31')  # one month only
    symbols = ['SPY', 'IBM', 'GOOG'] #
    df = get_data(symbols, dates)
    #plot_data(df)

    # Compute daily returns
    daily_returns = compute_daily_returns(df)
    #plot_data(daily_returns, title="Daily returns", ylabel="Daily returns")
    #plotHistogram(daily_returns)
    daily_returns.plot(kind='scatter', x='SPY', y='IBM')
    beta_IBM, alpha_IBM = np.polyfit(daily_returns['SPY'], daily_returns['IBM'], 1)
    plt.plot(daily_returns['SPY'], beta_IBM*daily_returns['SPY'] + alpha_IBM, '-', color='r')

    print "beta_IBM= ", beta_IBM
    print "alpha_IBM= ", alpha_IBM



    daily_returns.plot(kind='scatter', x='SPY', y='GOOG')
    beta_GOOG, alpha_GOOG = np.polyfit(daily_returns['SPY'], daily_returns['GOOG'], 1)
    plt.plot(daily_returns['SPY'], beta_GOOG * daily_returns['SPY'] + alpha_GOOG, '-', color='r')


    print "beta_GOOG= ", beta_GOOG
    print "alpha_GOOG= ", alpha_GOOG

    print daily_returns.corr(method='pearson')

    plt.show()

if __name__ == "__main__":
    test_run_daily_returns()
