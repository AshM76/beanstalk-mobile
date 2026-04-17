class LessonSlide {
  final String title;
  final String body;
  const LessonSlide({required this.title, required this.body});
}

class LessonQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  const LessonQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class LessonContent {
  final String lessonId;
  final List<LessonSlide> slides;
  final List<LessonQuizQuestion> quiz;
  const LessonContent({
    required this.lessonId,
    required this.slides,
    required this.quiz,
  });
}

const kLessonContent = <String, LessonContent>{

  'l1': LessonContent(
    lessonId: 'l1',
    slides: [
      LessonSlide(
        title: 'What is a Stock?',
        body: 'A stock represents a small ownership stake in a company.\n\n'
            'When a company wants to raise money it sells pieces of itself to the public. '
            'Each piece is called a share. If a company has 1,000,000 shares and you own '
            '1,000 of them, you own 0.1% of that company.\n\n'
            'Stocks trade on exchanges like the NYSE and NASDAQ where buyers and sellers '
            'meet to agree on a price.',
      ),
      LessonSlide(
        title: 'How Do You Make Money?',
        body: 'There are two ways stocks make you money:\n\n'
            '1. Price appreciation - you buy at \$10 and it rises to \$15. '
            'You made \$5 per share (50% return).\n\n'
            '2. Dividends - some companies share profits with shareholders as '
            'regular cash payments. Coca-Cola pays about \$1.84 per share per year.\n\n'
            'Not all stocks pay dividends. Fast-growing companies like Amazon '
            'reinvest profits back into the business instead.',
      ),
      LessonSlide(
        title: 'Why Do Stock Prices Move?',
        body: 'Stock prices change every second based on supply and demand.\n\n'
            'Price goes UP when:\n'
            '- Company reports strong earnings\n'
            '- A new product excites investors\n'
            '- Economy is doing well\n'
            '- More buyers than sellers\n\n'
            'Price goes DOWN when:\n'
            '- Company misses earnings targets\n'
            '- Bad news hits (scandal, lawsuit)\n'
            '- Economy slows\n'
            '- More sellers than buyers\n\n'
            'Short term: prices follow emotion. Long term: prices follow performance.',
      ),
      LessonSlide(
        title: 'Stocks vs Other Investments',
        body: 'Stocks are one of several asset classes:\n\n'
            'Stocks - ownership in companies. Higher risk, higher return. '
            'Historically about 10% average annual return (S&P 500).\n\n'
            'Bonds - loans to companies or governments. Lower risk, lower return (3-5%).\n\n'
            'Cash - safest, but loses value to inflation over time.\n\n'
            'Real Estate - property ownership. Rental income and appreciation.\n\n'
            'For long-term wealth building, stocks have outperformed all other '
            'asset classes over the past 100 years.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'What does owning a stock actually mean?',
        options: ['Lending money to a company', 'Owning a small piece of a company', 'A guaranteed fixed return', 'Controlling company decisions'],
        correctIndex: 1,
        explanation: 'A stock represents ownership (equity) in a company. As a shareholder you own a proportional slice of the business including its assets, earnings, and future growth.',
      ),
      LessonQuizQuestion(
        question: 'A company has 1,000,000 shares and you buy 10,000. What percentage do you own?',
        options: ['0.001%', '0.1%', '1%', '10%'],
        correctIndex: 2,
        explanation: '10,000 divided by 1,000,000 = 0.01 = 1%. Your percentage equals your shares divided by total shares outstanding.',
      ),
      LessonQuizQuestion(
        question: 'Which of these is NOT a way to make money from stocks?',
        options: ['Price appreciation', 'Dividend payments', 'Guaranteed annual interest', 'Selling at a higher price'],
        correctIndex: 2,
        explanation: 'Stocks do not pay guaranteed interest - that is bonds. Stocks make money through price appreciation and dividends. There are no guarantees.',
      ),
    ],
  ),

  'l2': LessonContent(
    lessonId: 'l2',
    slides: [
      LessonSlide(
        title: 'What is a Stock Market?',
        body: 'A stock market is an organised marketplace where buyers and sellers '
            'trade shares in public companies.\n\n'
            'The two biggest US exchanges:\n\n'
            'NYSE (New York Stock Exchange) - oldest and largest, founded in 1792. '
            'Trades Walmart, JPMorgan, Coca-Cola.\n\n'
            'NASDAQ - tech-heavy exchange founded in 1971. '
            'Home to Apple, Microsoft, Amazon, Google.\n\n'
            'US markets are open Monday to Friday, 9:30am to 4:00pm Eastern Time.',
      ),
      LessonSlide(
        title: 'How a Trade Works',
        body: 'When you place a buy order here is what happens:\n\n'
            '1. You enter: Buy 5 shares of AAPL\n'
            '2. Your broker sends the order to the exchange\n'
            '3. The exchange matches you with a seller\n'
            '4. The trade executes - shares transfer to you, cash to the seller\n'
            '5. Settlement happens in T+2 (2 business days)\n\n'
            'This all happens in milliseconds. Modern exchanges process '
            'millions of trades per second.',
      ),
      LessonSlide(
        title: 'Market Indices',
        body: 'You have heard "the market was up today" - but what does that mean?\n\n'
            'Market indices track a basket of stocks:\n\n'
            'S&P 500 - tracks the 500 largest US companies. The most widely used benchmark.\n\n'
            'Dow Jones (DJIA) - tracks just 30 major companies. Older and less representative.\n\n'
            'NASDAQ Composite - tracks all NASDAQ stocks, heavily weighted toward tech.\n\n'
            'When people say "the market is up" they usually mean the S&P 500.',
      ),
      LessonSlide(
        title: 'Bull and Bear Markets',
        body: 'Two terms you will hear constantly:\n\n'
            'Bull Market - prices rising, investor confidence high. '
            'Officially defined as a 20%+ rise from a recent low. '
            'The longest bull market ran from 2009 to 2020.\n\n'
            'Bear Market - prices falling, fear dominates. '
            'Defined as a 20%+ decline from a recent high. '
            'Bear markets average about 9 to 10 months.\n\n'
            'Key fact: Since 1928 the S&P 500 has had 27 bear markets '
            'but has always recovered and gone on to new highs.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'What are the standard US stock market hours?',
        options: ['8am to 5pm ET', '9:30am to 4pm ET', '9am to 5pm ET', '24 hours a day'],
        correctIndex: 1,
        explanation: 'US stock markets are open Monday to Friday, 9:30am to 4:00pm Eastern Time. Pre-market and after-hours trading exists but with much lower volume.',
      ),
      LessonQuizQuestion(
        question: 'The S&P 500 is up 15% this year. What does this mean?',
        options: ['500 stocks each rose 15%', 'The weighted average of 500 large US companies rose about 15%', 'Every US stock rose 15%', 'The Dow Jones rose 15%'],
        correctIndex: 1,
        explanation: 'The S&P 500 is a weighted index of 500 large US companies. When it rises 15% it means the weighted average value of those companies increased by about 15%.',
      ),
      LessonQuizQuestion(
        question: 'How is a bear market officially defined?',
        options: ['Any month stocks fall', 'A 10% decline from highs', 'A 20%+ decline from highs', 'A recession over 6 months'],
        correctIndex: 2,
        explanation: 'A bear market is defined as a 20% or greater decline from a recent market high. The S&P 500 has had 27 bear markets since 1928 and has recovered from every single one.',
      ),
    ],
  ),

  'l3': LessonContent(
    lessonId: 'l3',
    slides: [
      LessonSlide(
        title: 'What is a Stock Chart?',
        body: 'A stock chart is a visual history of a stock\'s price over time.\n\n'
            'The most common type is the line chart - it plots the closing price '
            'each day and connects the dots.\n\n'
            'The X axis (horizontal) = time.\n'
            'The Y axis (vertical) = price.\n\n'
            'When the line goes up, the stock is appreciating. '
            'When it goes down, it is declining. '
            'The steeper the slope, the faster the move.',
      ),
      LessonSlide(
        title: 'Candlestick Charts',
        body: 'Professional traders use candlestick charts which show 4 data points per period:\n\n'
            'Open - price at market open\n'
            'Close - price at market close\n'
            'High - highest price of the day\n'
            'Low - lowest price of the day\n\n'
            'Green candle = price closed HIGHER than it opened (bullish)\n'
            'Red candle = price closed LOWER than it opened (bearish)\n\n'
            'The thin lines above and below (wicks) show the high and low range.',
      ),
      LessonSlide(
        title: 'Volume and Moving Averages',
        body: 'Two key indicators to add to any chart:\n\n'
            'Volume - the number of shares traded. High volume confirms a price '
            'move is significant. A big move on low volume is less convincing.\n\n'
            'Moving Averages (MA) - the average price over a set period:\n'
            '50-day MA - medium term trend\n'
            '200-day MA - long term trend\n\n'
            'When price crosses above its 200-day MA, many traders see it as '
            'a bullish signal. Below = bearish.',
      ),
      LessonSlide(
        title: 'Support and Resistance',
        body: 'Two of the most important concepts in chart reading:\n\n'
            'Support - a price level where a stock has repeatedly bounced upward. '
            'Think of it as a floor. Buyers tend to step in at this level.\n\n'
            'Resistance - a price level where a stock has repeatedly failed to break '
            'through. Think of it as a ceiling. Sellers tend to step in here.\n\n'
            'When a stock breaks through resistance, that level often becomes '
            'the new support.\n\n'
            'The more times a level has been tested, the more significant it is.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'On a candlestick chart, what does a green candle mean?',
        options: ['Price fell during the period', 'Price rose during the period', 'Volume was high', 'The stock hit a new high'],
        correctIndex: 1,
        explanation: 'A green candlestick means the closing price was higher than the opening price - the stock rose during that period. A red candle means it fell.',
      ),
      LessonQuizQuestion(
        question: 'What does high volume during a price move tell you?',
        options: ['The move is less reliable', 'The move is more significant and confirmed', 'The stock is about to reverse', 'Nothing important'],
        correctIndex: 1,
        explanation: 'High volume confirms conviction behind a price move. Many buyers or sellers are participating, making the move more meaningful. Low volume moves are less reliable.',
      ),
      LessonQuizQuestion(
        question: 'A stock drops to \$50 and bounces back up — this has happened three times. What is \$50 called?',
        options: ['Resistance level', 'Moving average', 'Support level', 'Fair value'],
        correctIndex: 2,
        explanation: 'A price level where a stock repeatedly bounces upward is called support - it acts like a floor. The more times it has been tested, the stronger that support level becomes.',
      ),
    ],
  ),

  'l4': LessonContent(
    lessonId: 'l4',
    slides: [
      LessonSlide(
        title: 'What is a Bid and Ask?',
        body: 'Every stock has two prices at any moment:\n\n'
            'Bid price - the highest price a buyer is willing to pay right now.\n'
            'Ask price - the lowest price a seller is willing to accept right now.\n\n'
            'Example: AAPL Bid: \$182.50 | Ask: \$182.55\n\n'
            'If you want to buy immediately, you pay the Ask (\$182.55).\n'
            'If you want to sell immediately, you receive the Bid (\$182.50).\n\n'
            'The market price you see quoted is usually the last traded price.',
      ),
      LessonSlide(
        title: 'The Spread',
        body: 'The spread is the difference between the bid and ask price.\n\n'
            'Spread = Ask minus Bid\n'
            'Example: \$182.55 - \$182.50 = \$0.05\n\n'
            'The spread is effectively a hidden cost of trading. When you buy '
            'at the ask and could only immediately sell at the bid, '
            'you start slightly underwater.\n\n'
            'Tight spreads = liquid stock, easy to trade. '
            'Apple and large ETFs have spreads of just 1 cent.\n\n'
            'Wide spreads = illiquid stock. Small stocks can have spreads '
            'of 1-2% or more.',
      ),
      LessonSlide(
        title: 'Market Orders vs Limit Orders',
        body: 'When you place a trade you choose an order type:\n\n'
            'Market Order - execute immediately at the best available price. '
            'Fast and guaranteed to fill, but you accept whatever the current '
            'ask price is. Good for liquid stocks.\n\n'
            'Limit Order - you set the maximum price you will pay (buy) or '
            'minimum you will accept (sell). Only executes if the market '
            'reaches your price. Better price control but not guaranteed to fill.\n\n'
            'Example: AAPL is at \$182.55. You place a limit buy at \$181.00. '
            'Your order only fills if AAPL drops to \$181 or below.',
      ),
      LessonSlide(
        title: 'Slippage',
        body: 'Slippage is when you get a different price than expected.\n\n'
            'It happens most often with:\n'
            '- Market orders on illiquid stocks\n'
            '- Large orders that move the market\n'
            '- Fast-moving markets during news events\n\n'
            'Example: you place a market buy for 10,000 shares of a small stock. '
            'The first 1,000 shares fill at \$10.00, but your large order pushes '
            'the price up - the rest fill at \$10.05, \$10.08...\n\n'
            'For most retail investors trading liquid stocks, slippage is minimal.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'AAPL Bid: \$150.00, Ask: \$150.05. If you want to buy immediately, what price do you pay?',
        options: ['\$150.00', '\$150.025', '\$150.05', 'The last traded price'],
        correctIndex: 2,
        explanation: 'When buying immediately with a market order you pay the Ask price - the lowest price a seller will currently accept. The Bid is what you would receive if selling immediately.',
      ),
      LessonQuizQuestion(
        question: 'A stock has a bid of \$10.00 and ask of \$10.50. What is the spread?',
        options: ['\$0.05', '\$0.50', '\$1.00', '5%'],
        correctIndex: 1,
        explanation: '\$10.50 minus \$10.00 = \$0.50 spread. This is 5% of the stock price - a very wide spread indicating an illiquid stock.',
      ),
      LessonQuizQuestion(
        question: 'You want to buy AAPL only if it drops to \$175. Which order type should you use?',
        options: ['Market order', 'Limit order', 'Stop order', 'Any order works the same'],
        correctIndex: 1,
        explanation: 'A limit order lets you specify the maximum price you will pay. Set a limit buy at \$175 and your order only executes if AAPL reaches that price.',
      ),
    ],
  ),

  'l5': LessonContent(
    lessonId: 'l5',
    slides: [
      LessonSlide(
        title: 'What is Diversification?',
        body: 'Diversification is spreading investments across different assets '
            'so that a single bad event cannot devastate your entire portfolio.\n\n'
            'The classic saying: Do not put all your eggs in one basket.\n\n'
            'If you put your entire savings into one stock and that company goes '
            'bankrupt, you lose everything. But if you spread across 20 stocks, '
            'one bankruptcy only costs you 5% of your portfolio.\n\n'
            'Diversification eliminates unnecessary risk without giving up returns.',
      ),
      LessonSlide(
        title: 'How Much Diversification?',
        body: 'Research shows most benefits of diversification kick in around '
            '20 to 30 stocks across different industries.\n\n'
            'Beyond that, adding more stocks has diminishing returns on risk reduction.\n\n'
            'A simple diversified portfolio might include:\n'
            '- US large-cap stocks (S&P 500 ETF)\n'
            '- International stocks\n'
            '- Bonds\n'
            '- Real estate (REIT)\n\n'
            'The easiest way to diversify instantly: buy a total market ETF '
            'like VTI which holds over 3,500 US companies in one purchase.',
      ),
      LessonSlide(
        title: 'Correlation - The Key to True Diversification',
        body: 'True diversification requires assets that do not all move together.\n\n'
            'Correlation measures how similarly two assets move:\n'
            '+1.0 = move in perfect lockstep (not diversifying)\n'
            '0.0 = no relationship\n'
            '-1.0 = move in opposite directions (perfect hedge)\n\n'
            'Owning Apple AND Microsoft is not great diversification - both are '
            'US tech stocks that fall together in downturns.\n\n'
            'Better: stocks plus bonds. When stocks crash, investors often flee '
            'to bonds, pushing bond prices up. This softens portfolio losses.',
      ),
      LessonSlide(
        title: 'Over-Diversification',
        body: 'It is possible to over-diversify - owning so many assets that:\n\n'
            '1. Your returns are dragged down to the average\n'
            '2. You cannot track or understand your holdings\n'
            '3. Transaction costs eat into gains\n\n'
            'Warren Buffett famously said: "Diversification is protection against '
            'ignorance. It makes little sense if you know what you are doing."\n\n'
            'For most investors though, especially beginners, broad diversification '
            'through low-cost index funds is the smartest starting point. '
            'You beat the majority of professional fund managers simply by '
            'owning everything.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'You own 1 stock and it goes bankrupt. You own 20 equal stocks and one goes bankrupt. What is the difference in loss?',
        options: ['Same loss both ways', '100% loss vs 5% loss', '50% loss vs 5% loss', '100% loss vs 20% loss'],
        correctIndex: 1,
        explanation: 'With 1 stock: 100% loss. With 20 equally-weighted stocks: 1/20 = 5% loss. This is the power of diversification.',
      ),
      LessonQuizQuestion(
        question: 'Which pair of assets provides better diversification?',
        options: ['Apple and Microsoft', 'US stocks and international stocks', 'Two tech ETFs', 'Growth stocks and more growth stocks'],
        correctIndex: 1,
        explanation: 'US stocks and international stocks have lower correlation than two US tech companies. True diversification comes from assets that do not all move together.',
      ),
      LessonQuizQuestion(
        question: 'What is the easiest way to instantly own 3,500+ US stocks?',
        options: ['Buy each stock individually', 'Buy a total market ETF like VTI', 'Open multiple brokerage accounts', 'Buy the 10 largest companies'],
        correctIndex: 1,
        explanation: 'A total market ETF like VTI holds thousands of stocks in one purchase. It gives instant, broad diversification at very low cost.',
      ),
    ],
  ),

  'l6': LessonContent(
    lessonId: 'l6',
    slides: [
      LessonSlide(
        title: 'What is Risk?',
        body: 'In investing, risk is the possibility that your actual return '
            'will differ from your expected return.\n\n'
            'Risk comes in several forms:\n\n'
            'Market Risk - the whole market falls (2008, 2020 COVID crash)\n'
            'Company Risk - a specific company fails (Enron, Lehman Brothers)\n'
            'Inflation Risk - your returns do not keep up with inflation\n'
            'Liquidity Risk - you cannot sell when you need to\n'
            'Concentration Risk - too much in one asset\n\n'
            'Not all risk is bad. Taking calculated risk is how you earn '
            'returns above cash.',
      ),
      LessonSlide(
        title: 'The Risk-Return Tradeoff',
        body: 'The fundamental rule of investing: higher potential return '
            'always comes with higher risk.\n\n'
            'Historical average annual returns:\n'
            'Cash/savings: 1-2%\n'
            'Government bonds: 3-4%\n'
            'Corporate bonds: 4-6%\n'
            'Large-cap stocks (S&P 500): about 10%\n'
            'Small-cap stocks: about 11-12%\n'
            'Crypto: potentially much higher or much lower\n\n'
            'If someone offers you high returns with no risk, it is a scam. '
            'Returns and risk are inseparable.',
      ),
      LessonSlide(
        title: 'Measuring Risk with Beta',
        body: 'Beta measures a stock\'s volatility relative to the market:\n\n'
            'Beta = 1.0: moves with the market\n'
            'Beta > 1.0: more volatile than the market (e.g. Tesla around 2.0)\n'
            'Beta < 1.0: less volatile (e.g. Johnson and Johnson around 0.5)\n\n'
            'High-beta stocks rise more in bull markets but fall harder in bear markets.\n'
            'Low-beta stocks are steadier but cap your upside.\n\n'
            'Standard deviation measures how much a price swings overall. '
            'High standard deviation = wild swings. '
            'Low standard deviation = smoother ride.',
      ),
      LessonSlide(
        title: 'Your Personal Risk Tolerance',
        body: 'Risk tolerance is how much volatility you can stomach '
            'without panic-selling.\n\n'
            'Factors that affect it:\n\n'
            'Time horizon - the longer until you need the money, the more '
            'risk you can take. A 25-year-old can handle more volatility '
            'than a 60-year-old.\n\n'
            'Financial cushion - if you have emergency savings, you can '
            'leave investments alone during downturns.\n\n'
            'General rule: subtract your age from 110. That percentage '
            'should be in stocks. At 20: 90% stocks. At 60: 50% stocks.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'A stock has a beta of 2.0. The market falls 10%. How much might this stock fall?',
        options: ['5%', '10%', '20%', '2%'],
        correctIndex: 2,
        explanation: 'Beta of 2.0 means the stock moves roughly twice as much as the market. If the market falls 10%, this stock might fall about 20%.',
      ),
      LessonQuizQuestion(
        question: 'Which investment historically has the highest long-term return?',
        options: ['Government bonds', 'Cash in savings', 'Large-cap stocks', 'Corporate bonds'],
        correctIndex: 2,
        explanation: 'Large-cap stocks (S&P 500) have returned approximately 10% per year historically - far above bonds and cash. This higher return compensates for the higher volatility.',
      ),
      LessonQuizQuestion(
        question: 'You are 25 years old saving for retirement at 65. How should you think about short-term market crashes?',
        options: ['Sell everything immediately', 'Stay invested - you have 40 years to recover', 'Move to 20% stocks', 'Panic and move to cash'],
        correctIndex: 1,
        explanation: 'With a 40-year time horizon, short-term crashes are buying opportunities. Every major market crash in history has been followed by full recovery and new highs.',
      ),
    ],
  ),

  'l7': LessonContent(
    lessonId: 'l7',
    slides: [
      LessonSlide(
        title: 'What is Asset Allocation?',
        body: 'Asset allocation is how you divide your portfolio among different '
            'asset classes - stocks, bonds, cash, real estate, and alternatives.\n\n'
            'It is the single most important investment decision you will make. '
            'Research shows that asset allocation explains about 90% of portfolio '
            'performance variability over time - far more than individual stock selection.\n\n'
            'Think of it as your investment recipe. The ingredients and their '
            'proportions determine your expected return and risk level.',
      ),
      LessonSlide(
        title: 'Classic Allocation Models',
        body: 'Traditional models based on risk tolerance:\n\n'
            'Conservative:\n'
            '30% stocks / 60% bonds / 10% cash\n'
            'For: retirees, short time horizons\n\n'
            'Moderate:\n'
            '60% stocks / 35% bonds / 5% cash\n'
            'For: medium-term investors, balanced risk\n\n'
            'Aggressive:\n'
            '90% stocks / 10% bonds\n'
            'For: young investors, long time horizons\n\n'
            'The classic 60/40 portfolio has been a benchmark for decades.',
      ),
      LessonSlide(
        title: 'Rebalancing',
        body: 'Over time your allocation drifts as different assets grow at '
            'different rates.\n\n'
            'Example: you start with 70% stocks / 30% bonds. After a great '
            'year for stocks, you are now at 80% stocks / 20% bonds - '
            'more risk than intended.\n\n'
            'Rebalancing means selling what has grown and buying what has '
            'lagged to return to your target.\n\n'
            'How often to rebalance:\n'
            '- Calendar: once or twice per year\n'
            '- Threshold: when any asset drifts more than 5% from target\n\n'
            'Rebalancing automatically forces you to buy low and sell high.',
      ),
      LessonSlide(
        title: 'Modern Portfolio Theory',
        body: 'Harry Markowitz won the Nobel Prize in 1952 for Modern Portfolio '
            'Theory - the mathematics behind diversification.\n\n'
            'Key insight: you can combine risky assets in a way that reduces '
            'overall portfolio risk without sacrificing return.\n\n'
            'The Efficient Frontier: for any level of return, there is an optimal '
            'portfolio that achieves it with minimum possible risk.\n\n'
            'Practical takeaway: a diversified mix of assets with low correlation '
            'gives you the best risk-adjusted return. This is why simple index '
            'fund portfolios beat most active managers over time.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'Research shows asset allocation explains roughly what percentage of portfolio performance?',
        options: ['10%', '50%', '90%', '100%'],
        correctIndex: 2,
        explanation: 'Studies show that asset allocation explains approximately 90% of portfolio return variability. Stock picking and market timing account for the remaining 10%.',
      ),
      LessonQuizQuestion(
        question: 'You target 70% stocks / 30% bonds. After a bull market you are at 85% / 15%. What should you do?',
        options: ['Do nothing', 'Sell some stocks and buy bonds to rebalance', 'Sell all bonds', 'Add more stocks'],
        correctIndex: 1,
        explanation: 'Rebalancing means selling assets above your target and buying those below. Here you would sell some stocks and buy bonds - effectively selling high and buying low.',
      ),
      LessonQuizQuestion(
        question: 'Which allocation is most appropriate for a 22-year-old with a 40-year investment horizon?',
        options: ['30% stocks / 70% bonds', '50% stocks / 50% bonds', '90% stocks / 10% bonds', '100% cash'],
        correctIndex: 2,
        explanation: 'A 22-year-old with 40 years until retirement can tolerate high volatility because they have decades to recover. An aggressive allocation maximises long-term growth.',
      ),
    ],
  ),

  'l8': LessonContent(
    lessonId: 'l8',
    slides: [
      LessonSlide(
        title: 'What is an ETF?',
        body: 'An Exchange-Traded Fund (ETF) is a basket of securities that '
            'trades on a stock exchange like a single stock.\n\n'
            'When you buy one share of SPY (S&P 500 ETF), you instantly own '
            'a tiny slice of all 500 companies in the S&P 500 - Apple, '
            'Microsoft, Amazon, and 497 more.\n\n'
            'ETFs combine the diversification of a mutual fund with the '
            'trading flexibility of a stock.\n\n'
            'The ETF industry has grown from \$1 billion in 1993 to over '
            '\$10 trillion today.',
      ),
      LessonSlide(
        title: 'ETF vs Mutual Fund',
        body: 'ETFs and mutual funds both hold baskets of securities but differ:\n\n'
            'Trading: ETFs trade like stocks (real-time). '
            'Mutual funds price once daily after market close.\n\n'
            'Minimum investment: ETFs - one share (can be \$50-500). '
            'Mutual funds - often \$1,000 to \$3,000 minimum.\n\n'
            'Costs: ETFs are typically cheaper. '
            'Average ETF expense ratio: 0.16%. '
            'Average mutual fund: 0.66%.\n\n'
            'For most individual investors, ETFs win on almost every dimension.',
      ),
      LessonSlide(
        title: 'Index vs Active',
        body: 'Most funds fall into two camps:\n\n'
            'Index funds - passively track a market index. Low cost, '
            'no manager making decisions.\n'
            'Vanguard S&P 500 ETF (VOO): 0.03% expense ratio\n'
            'Total market (VTI): 0.03%\n\n'
            'Active funds - a manager actively picks stocks trying to beat '
            'the market. Higher cost, usually underperform.\n'
            'Average active fund: 0.66% expense ratio\n\n'
            'The evidence is clear: over 15 years, more than 90% of active '
            'fund managers underperform their benchmark index after fees.',
      ),
      LessonSlide(
        title: 'Leveraged ETFs - Handle with Care',
        body: 'Leveraged ETFs aim to deliver 2x or 3x the daily return of an index.\n\n'
            'SSO = 2x S&P 500. If S&P rises 1% today, SSO targets +2%.\n'
            'SPXL = 3x S&P 500. If S&P rises 1%, SPXL targets +3%.\n\n'
            'The catch - daily reset and volatility decay:\n'
            'If the index falls 10% then rises 10%, you are NOT back to even.\n\n'
            'Example: Index at -10% then +10%: 90 x 1.10 = \$99.\n'
            'A 3x fund: -30% then +30%: 70 x 1.30 = \$91.\n\n'
            'Leveraged ETFs are short-term trading tools, not long-term investments.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'What happens when you buy one share of a S&P 500 ETF?',
        options: ['You own stock in one large company', 'You own a tiny slice of 500 companies', 'You lend money to 500 companies', 'You get a guaranteed 10% return'],
        correctIndex: 1,
        explanation: 'An S&P 500 ETF holds all 500 companies in the index. Buying one share gives you proportional ownership in all of them.',
      ),
      LessonQuizQuestion(
        question: 'Over 15 years, what percentage of active fund managers underperform their index?',
        options: ['About 30%', 'About 50%', 'About 70%', 'Over 90%'],
        correctIndex: 3,
        explanation: 'Research consistently shows over 90% of active managers underperform their benchmark index over 15+ year periods after fees.',
      ),
      LessonQuizQuestion(
        question: 'Why are leveraged ETFs unsuitable for long-term buy-and-hold investing?',
        options: ['They are too expensive', 'Daily reset causes volatility decay that erodes returns over time', 'They do not pay dividends', 'They are too diversified'],
        correctIndex: 1,
        explanation: 'Leveraged ETFs reset daily, which causes volatility decay. In choppy markets they can lose money even if the underlying index is flat. They are designed for short-term trading only.',
      ),
    ],
  ),

  'l9': LessonContent(
    lessonId: 'l9',
    slides: [
      LessonSlide(
        title: 'Why Invest in Real Estate?',
        body: 'Real estate is one of the oldest forms of wealth-building.\n\n'
            'Three ways it makes you money:\n\n'
            '1. Appreciation - US home prices have averaged about 4% annual '
            'growth historically.\n\n'
            '2. Rental income - tenants pay you every month.\n\n'
            '3. Equity build-up - every mortgage payment increases your '
            'ownership stake.\n\n'
            'The catch: real estate requires significant capital upfront, '
            'is illiquid (hard to sell quickly), and has ongoing costs - '
            'maintenance, taxes, insurance, and vacancies.',
      ),
      LessonSlide(
        title: 'Mortgages and Interest Rates',
        body: 'Most people buy property using a mortgage - a loan secured '
            'by the property.\n\n'
            'Fixed-Rate Mortgage - your rate never changes. Predictable '
            'payments for 15 or 30 years. Best when rates are low.\n\n'
            'Adjustable-Rate (ARM) - starts low for 5 to 7 years, then '
            'adjusts with the market. Risky if rates rise sharply.\n\n'
            'Interest-Only - pay only interest for a set period. Used by '
            'investors for short-term holds.\n\n'
            'Why rates matter: at 3%, a \$400,000 mortgage costs \$1,686/month. '
            'At 7%, the same loan costs \$2,661/month - \$975 more every month.',
      ),
      LessonSlide(
        title: 'The Power of Leverage',
        body: 'Leverage means using borrowed money to control a larger asset.\n\n'
            'Example with 20% down:\n'
            'You put \$80,000 down on a \$400,000 property.\n'
            'Property rises 10% to \$440,000.\n'
            'Your gain: \$40,000 - a 50% return on your \$80,000.\n\n'
            'Without leverage: 10% gain on \$80,000 = \$8,000 (10% return).\n'
            'With leverage: same 10% gain = \$40,000 (50% return).\n\n'
            'But it cuts both ways: if property falls 10%, your \$80,000 '
            'equity is wiped out - a 100% loss on just a 10% market drop.',
      ),
      LessonSlide(
        title: 'The 1% Rule and Cash Flow',
        body: 'The 1% Rule: monthly rent should be at least 1% of purchase price.\n'
            'A \$300,000 property should rent for at least \$3,000 per month.\n\n'
            'Cash flow = Rent minus mortgage minus taxes minus insurance '
            'minus maintenance minus vacancy reserve.\n\n'
            'Hidden costs first-timers forget:\n'
            '- Property management: 8 to 12% of rent\n'
            '- Vacancy: budget 1 month empty per year\n'
            '- Repairs: about 1% of property value per year\n'
            '- Big items: roofs, HVAC, appliances\n\n'
            'Cap Rate = Annual Net Operating Income divided by Property Price. '
            'A 6 to 8% cap rate is generally healthy.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'You put \$100,000 down on a \$500,000 property. It rises 10%. What is your return on investment?',
        options: ['10%', '20%', '50%', '100%'],
        correctIndex: 2,
        explanation: 'The property gained \$50,000 but you only invested \$100,000. \$50,000 divided by \$100,000 = 50% return. Leverage amplified your return 5 times.',
      ),
      LessonQuizQuestion(
        question: 'A property costs \$250,000. Using the 1% rule, what is the minimum monthly rent?',
        options: ['\$1,250', '\$2,500', '\$3,500', '\$5,000'],
        correctIndex: 1,
        explanation: '1% of \$250,000 = \$2,500 per month. If a property cannot generate this level of rent it is unlikely to cash flow positively after all expenses.',
      ),
      LessonQuizQuestion(
        question: 'Which mortgage type gives a guaranteed fixed payment for the full loan term?',
        options: ['Adjustable-Rate (ARM)', 'Interest-Only', 'Fixed-Rate', 'Balloon'],
        correctIndex: 2,
        explanation: 'A fixed-rate mortgage locks in your rate for the entire term - 15 or 30 years. ARMs start low but can jump significantly after the fixed period ends.',
      ),
    ],
  ),

  'l10': LessonContent(
    lessonId: 'l10',
    slides: [
      LessonSlide(
        title: 'What is a REIT?',
        body: 'A Real Estate Investment Trust (REIT) is a company that owns '
            'income-producing real estate and trades on the stock exchange '
            'like any other stock.\n\n'
            'By law REITs must:\n'
            '- Pay out at least 90% of taxable income as dividends\n'
            '- Own at least \$100M in real estate assets\n'
            '- Have at least 100 shareholders\n\n'
            'That 90% rule is why REITs offer high dividend yields - often '
            '4 to 8% annually vs about 1.5% for the S&P 500.\n\n'
            'Examples:\n'
            '- Prologis (PLD) - warehouses\n'
            '- Equinix (EQIX) - data centres\n'
            '- Realty Income (O) - monthly dividends',
      ),
      LessonSlide(
        title: 'Types of REITs',
        body: 'Equity REITs - own and operate properties. Income from rent. Most common.\n\n'
            'Mortgage REITs (mREITs) - lend money against properties. '
            'Higher yields but very sensitive to interest rate changes.\n\n'
            'By sector:\n'
            '- Industrial - warehouses (Amazon-driven demand)\n'
            '- Healthcare - hospitals, senior living\n'
            '- Residential - apartment complexes\n'
            '- Retail - shopping centres (struggling)\n'
            '- Office - corporate offices (struggling post-COVID)\n'
            '- Data Centre - fastest growing, driven by AI and cloud\n\n'
            'Data centre REITs have massively outperformed retail and office '
            'over the past decade.',
      ),
      LessonSlide(
        title: 'Residential vs Commercial Real Estate',
        body: 'Residential and commercial operate very differently:\n\n'
            'Residential:\n'
            '- Smaller deals (\$200K to \$2M)\n'
            '- Short leases (12 months)\n'
            '- Strong tenant protection laws\n'
            '- Easier financing\n\n'
            'Commercial:\n'
            '- Larger deals (\$1M to \$100M+)\n'
            '- Long leases (5 to 25 years)\n'
            '- Tenants often pay taxes and maintenance (NNN leases)\n'
            '- Valued by income: Value = NOI divided by Cap Rate\n\n'
            'A building generating \$500,000 NOI at 5% cap rate = worth \$10,000,000.',
      ),
      LessonSlide(
        title: 'Investing at Any Budget',
        body: 'You do not need a large down payment to invest in real estate:\n\n'
            '\$1+ - REITs via any brokerage. Buy VNQ (Vanguard Real Estate ETF).\n\n'
            '\$500+ - Real estate crowdfunding (Fundrise). Pool money with others.\n\n'
            '\$10,000 to \$50,000 - House hacking: buy a duplex, live in one unit, '
            'rent the others. Tenants help pay your mortgage.\n\n'
            '\$50,000+ - Buy-to-let rental property.\n\n'
            'VNQ highlights:\n'
            '- Broad US real estate exposure\n'
            '- About 4% dividend yield\n'
            '- 0.12% expense ratio\n'
            '- Instant diversification across hundreds of properties',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'By law REITs must distribute what percentage of taxable income as dividends?',
        options: ['At least 50%', 'At least 70%', 'At least 90%', '100%'],
        correctIndex: 2,
        explanation: 'REITs are legally required to pay at least 90% of taxable income as dividends. This is why REITs typically offer much higher yields than regular stocks.',
      ),
      LessonQuizQuestion(
        question: 'A building generates \$600,000 annual NOI at a 6% cap rate. What is it worth?',
        options: ['\$3,600,000', '\$6,000,000', '\$10,000,000', '\$36,000,000'],
        correctIndex: 2,
        explanation: 'Value = NOI divided by Cap Rate = \$600,000 divided by 0.06 = \$10,000,000. This is the foundation of commercial real estate valuation.',
      ),
      LessonQuizQuestion(
        question: 'Which REIT sector has grown fastest over the past decade?',
        options: ['Retail (malls)', 'Office buildings', 'Data centres', 'Hotels'],
        correctIndex: 2,
        explanation: 'Data centre REITs have been the fastest growing sector driven by cloud computing and AI infrastructure demand.',
      ),
    ],
  ),

  'l11': LessonContent(
    lessonId: 'l11',
    slides: [
      LessonSlide(
        title: 'What is Dollar-Cost Averaging?',
        body: 'Dollar-Cost Averaging (DCA) is investing a fixed amount at regular '
            'intervals regardless of whether the market is up or down.\n\n'
            'Example: invest \$200 every month in VOO (S&P 500 ETF).\n\n'
            'When prices are HIGH, your \$200 buys fewer shares.\n'
            'When prices are LOW, your \$200 buys more shares.\n\n'
            'Over time, this automatically ensures you buy more when stocks '
            'are cheap and less when they are expensive.\n\n'
            'DCA is the strategy used by anyone who contributes to a 401(k) '
            'automatically from their paycheck.',
      ),
      LessonSlide(
        title: 'DCA vs Lump Sum',
        body: 'If you have \$10,000 to invest, should you invest it all at once '
            '(lump sum) or spread it out (DCA)?\n\n'
            'The data: historically, lump sum investing outperforms DCA about '
            '2/3 of the time because markets tend to rise over time.\n\n'
            'But DCA wins on psychology:\n'
            '- Eliminates fear of investing at the top\n'
            '- Removes emotion from timing decisions\n'
            '- Smooths out entry price over time\n'
            '- Lets you sleep at night\n\n'
            'For regular savers investing monthly income, DCA is the natural '
            'and optimal approach.',
      ),
      LessonSlide(
        title: 'A Real DCA Example',
        body: 'Imagine investing \$500 per month in the S&P 500 starting '
            'January 2020 - right before COVID crashed markets 34%:\n\n'
            'January: \$500 at \$3,258 = 0.153 shares\n'
            'February: \$500 at \$2,954 = 0.169 shares (market falling)\n'
            'March: \$500 at \$2,304 = 0.217 shares (crash - buying more!)\n'
            'April: \$500 at \$2,912 = 0.172 shares (recovering)\n\n'
            'The March crash automatically bought more shares at the lowest prices. '
            'By end of 2020 the S&P 500 was UP for the year.\n\n'
            'Investors who stopped in March locked in losses. '
            'DCA investors who stayed the course captured the full recovery.',
      ),
      LessonSlide(
        title: 'Setting Up DCA',
        body: 'The beauty of DCA is its simplicity:\n\n'
            '1. Choose your investment (VOO, VTI, or a target-date fund)\n'
            '2. Decide your amount (\$50, \$200, \$500 - whatever fits your budget)\n'
            '3. Set the frequency (weekly, monthly, quarterly)\n'
            '4. Automate it - most brokerages allow recurring investments\n'
            '5. Do not check it obsessively - let it work\n\n'
            'The hardest part of DCA is not the maths - it is the psychology. '
            'Continuing to invest during a crash is what separates successful '
            'long-term investors from those who gave up.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'You invest \$300 per month. This month the stock price dropped 20%. What happens with DCA?',
        options: ['You skip this month', 'You invest less than usual', 'You automatically buy more shares than last month', 'You sell your existing shares'],
        correctIndex: 2,
        explanation: 'With DCA you invest the same dollar amount regardless of price. When price drops 20%, your \$300 buys 25% more shares than last month. DCA automatically has you buying more when stocks are on sale.',
      ),
      LessonQuizQuestion(
        question: 'Historically, which approach generates higher returns?',
        options: ['DCA always wins', 'Lump sum usually wins', 'They are always equal', 'Neither - cash is better'],
        correctIndex: 1,
        explanation: 'Studies show lump sum investing outperforms DCA about 2/3 of the time because markets tend to rise over time. However, DCA wins on psychology and risk management.',
      ),
      LessonQuizQuestion(
        question: 'What is the most important factor in making DCA work long-term?',
        options: ['Picking the right stocks', 'Perfect market timing', 'Consistency - investing through good and bad markets', 'Investing large amounts'],
        correctIndex: 2,
        explanation: 'The power of DCA comes from consistency. Investing through market crashes - when it feels most scary - is when you buy the most shares at the lowest prices.',
      ),
    ],
  ),

  'l12': LessonContent(
    lessonId: 'l12',
    slides: [
      LessonSlide(
        title: 'Value vs Growth',
        body: 'Two famous investing philosophies:\n\n'
            'Value Investing - buying stocks that appear underpriced relative to '
            'their intrinsic worth. Looking for bargains - \$1 of value for \$0.70.\n\n'
            'Growth Investing - buying stocks of rapidly growing companies even '
            'if the current price seems expensive. Paying for future potential.\n\n'
            'Value investing was pioneered by Benjamin Graham and perfected by '
            'Warren Buffett.\n\n'
            'Growth investing is exemplified by companies like Amazon and Tesla '
            'which traded at high valuations for years while building their empires.',
      ),
      LessonSlide(
        title: 'How Value Investors Think',
        body: 'Value investors look for stocks trading below intrinsic value:\n\n'
            'P/E Ratio (Price-to-Earnings) - stock price divided by annual earnings. '
            'A low P/E suggests a potentially cheap stock. '
            'S&P 500 average is about 20 to 25x. A stock at 10x might be a bargain.\n\n'
            'P/B Ratio (Price-to-Book) - stock price vs company net assets. '
            'Below 1.0 means buying the company for less than its assets are worth.\n\n'
            'The risk: sometimes stocks are cheap for a reason (value trap). '
            'The company might be in permanent decline.',
      ),
      LessonSlide(
        title: 'How Growth Investors Think',
        body: 'Growth investors focus on:\n\n'
            'Revenue growth - is the company growing sales rapidly? '
            '20%+ annually is exciting.\n\n'
            'Total Addressable Market (TAM) - how big is the opportunity? '
            'Amazon saw all of retail as its TAM.\n\n'
            'Market share - is the company taking share from competitors?\n\n'
            'Growth stocks often have high P/E ratios (50x, 100x, even higher) '
            'because investors are paying for future earnings, not current ones.\n\n'
            'The risk: if growth slows, the valuation can collapse brutally.',
      ),
      LessonSlide(
        title: 'Which is Better?',
        body: 'The debate has raged for decades:\n\n'
            'Historically, value stocks have outperformed growth stocks over '
            'very long periods. This is known as the "value premium."\n\n'
            'But the 2010s were dominated by growth stocks (tech giants crushed value). '
            'The 2022 rate hike cycle crushed growth while value held up.\n\n'
            'Most sophisticated investors blend both:\n'
            '- Core: broad index funds (get both automatically)\n'
            '- Tilt: small allocation to value or growth based on conviction\n\n'
            'For beginners: a total market index fund holds both value and growth '
            'stocks automatically. No need to choose.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'A stock has a P/E ratio of 8 while its industry average is 20. What might a value investor conclude?',
        options: ['The stock is overpriced', 'The stock may be undervalued and worth investigating', 'The company is growing fast', 'The stock is definitely a buy'],
        correctIndex: 1,
        explanation: 'A P/E of 8 vs industry average of 20 suggests the stock might be undervalued. Value investors would investigate WHY it is cheap - is it a genuine bargain or a value trap?',
      ),
      LessonQuizQuestion(
        question: 'A growth company has a P/E of 80x but is growing revenue at 40% per year. Is it necessarily overvalued?',
        options: ['Yes - 80x P/E is always too expensive', 'No - high growth can justify high valuations', 'P/E does not matter for growth stocks', 'Only if it pays no dividend'],
        correctIndex: 1,
        explanation: 'High P/E ratios can be justified for rapidly growing companies. If a company grows earnings 40% per year, it will earn its current valuation in just a few years.',
      ),
      LessonQuizQuestion(
        question: 'For a beginner, what is the simplest way to get exposure to both value and growth stocks?',
        options: ['Buy separate value and growth ETFs', 'Pick individual stocks from each category', 'Buy a total market index fund', 'Only buy dividend stocks'],
        correctIndex: 2,
        explanation: 'A total market index fund like VTI automatically holds all stocks - both value and growth - in proportion to their market capitalisation.',
      ),
    ],
  ),

  'l13': LessonContent(
    lessonId: 'l13',
    slides: [
      LessonSlide(
        title: 'What are Dividends?',
        body: 'A dividend is a cash payment made by a company to its shareholders, '
            'typically every quarter.\n\n'
            'Example: Coca-Cola pays \$0.46 per share every quarter (\$1.84 per year). '
            'If you own 100 shares, you receive \$184 per year in cash - automatically '
            'deposited into your account.\n\n'
            'Not all companies pay dividends. Young, fast-growing companies like Amazon '
            'reinvest all profits back into growth.\n\n'
            'Mature, stable companies (utilities, consumer staples, banks) tend to '
            'pay generous dividends.',
      ),
      LessonSlide(
        title: 'Dividend Yield and Payout Ratio',
        body: 'Two key metrics for dividend investors:\n\n'
            'Dividend Yield = Annual dividend per share divided by stock price.\n'
            'Example: \$1.84 dividend / \$60 stock price = 3.07% yield.\n\n'
            'A high yield (5%+) can signal a generous dividend OR a falling stock '
            'price - which is dangerous. Always investigate why the yield is high.\n\n'
            'Payout Ratio = Dividends paid divided by earnings.\n'
            'Example: company earns \$4/share, pays \$2/share = 50% payout ratio.\n\n'
            'A payout ratio over 100% means the company pays out more than it earns - '
            'unsustainable.',
      ),
      LessonSlide(
        title: 'Dividend Growth Investing',
        body: 'The most powerful dividend strategy is not chasing the highest yield - '
            'it is buying companies that consistently grow their dividends.\n\n'
            'Dividend Aristocrats - S&P 500 companies that have increased dividends '
            'for 25+ consecutive years. Examples:\n'
            '- Johnson & Johnson: 60+ years\n'
            '- Coca-Cola: 60+ years\n'
            '- Procter & Gamble: 66+ years\n\n'
            'Why growth matters: if you buy a stock yielding 2% today but the '
            'dividend grows 10% per year, in 10 years your yield on original '
            'cost is 5.2%. In 20 years it is 13.5%.',
      ),
      LessonSlide(
        title: 'DRIP - Dividend Reinvestment',
        body: 'DRIP stands for Dividend Reinvestment Plan - automatically using '
            'dividends to buy more shares instead of taking the cash.\n\n'
            'Why DRIP is powerful:\n\n'
            '\$10,000 in the S&P 500 in 1993, dividends taken as cash: '
            'grows to about \$52,000 by 2023.\n\n'
            '\$10,000 in the S&P 500 in 1993, dividends reinvested: '
            'grows to about \$182,000 by 2023.\n\n'
            'Reinvesting dividends accounts for roughly 40% of total stock market '
            'returns over long periods.\n\n'
            'Most brokerages offer free automatic DRIP. Turn it on and forget it.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'A stock pays \$3 per year in dividends and trades at \$60. What is the dividend yield?',
        options: ['3%', '5%', '20%', '0.5%'],
        correctIndex: 1,
        explanation: '\$3 divided by \$60 = 0.05 = 5% dividend yield. For every \$100 invested, you receive \$5 per year in dividend income.',
      ),
      LessonQuizQuestion(
        question: 'A company earns \$5 per share and pays \$6 per share in dividends. What is the problem?',
        options: ['The yield is too low', 'The payout ratio exceeds 100% and is unsustainable', 'The dividend should be higher', 'Nothing - this is ideal'],
        correctIndex: 1,
        explanation: 'A payout ratio over 100% means the company pays out more than it earns. This is unsustainable and usually signals a dividend cut is coming.',
      ),
      LessonQuizQuestion(
        question: 'What does DRIP stand for and why does it matter?',
        options: ['Daily Returns Investment Plan', 'Dividend Reinvestment Plan - automatically buys more shares with dividends', 'Diversified Risk Investment Portfolio', 'None of the above'],
        correctIndex: 1,
        explanation: 'DRIP automatically reinvests dividends to buy more shares. This compounding dramatically boosts long-term returns - historically accounting for about 40% of total stock market returns.',
      ),
    ],
  ),

  'l14': LessonContent(
    lessonId: 'l14',
    slides: [
      LessonSlide(
        title: 'What is Technical Analysis?',
        body: 'Technical analysis (TA) is the study of past price and volume data '
            'to forecast future price movements.\n\n'
            'Unlike fundamental analysis (which looks at company financials), '
            'technical analysis only looks at the chart.\n\n'
            'The theory: all known information about a stock is already reflected '
            'in its price. Chart patterns reveal the psychology of buyers and sellers.\n\n'
            'TA is widely used by short-term traders. Long-term investors tend '
            'to rely more on fundamentals. Most professionals use a combination.',
      ),
      LessonSlide(
        title: 'Trends and Trend Lines',
        body: 'The most fundamental concept: the trend is your friend.\n\n'
            'Uptrend - series of higher highs and higher lows. '
            'Each peak and trough is higher than the last. '
            'Trend line drawn along the lows.\n\n'
            'Downtrend - series of lower highs and lower lows. '
            'Trend line drawn along the highs.\n\n'
            'Sideways - no clear direction, price oscillates in a range.\n\n'
            'Rule: trade in the direction of the trend. '
            'In an uptrend, look for buying opportunities on pullbacks. '
            'Trend changes when price breaks decisively through the trend line.',
      ),
      LessonSlide(
        title: 'RSI - Relative Strength Index',
        body: 'RSI is one of the most popular momentum indicators. '
            'It measures how fast and how much a stock has moved, on a scale of 0 to 100.\n\n'
            'RSI above 70 = overbought. Stock has risen quickly. May be due for a pullback.\n'
            'RSI below 30 = oversold. Stock has fallen quickly. May be due for a bounce.\n'
            'RSI 40 to 60 = neutral territory.\n\n'
            'Example: AAPL RSI hits 85 after a 3-week rally. Traders might take '
            'some profits expecting a short-term pullback.\n\n'
            'Important: strong trending stocks can stay overbought for weeks. '
            'RSI is one input - never use any single indicator in isolation.',
      ),
      LessonSlide(
        title: 'MACD and Putting It Together',
        body: 'MACD (Moving Average Convergence Divergence) shows the relationship '
            'between two moving averages.\n\n'
            'Bullish signal: MACD line crosses ABOVE the signal line.\n'
            'Bearish signal: MACD line crosses BELOW the signal line.\n\n'
            'Putting TA together - a trader might look for:\n'
            '1. Stock in uptrend (higher highs and lows)\n'
            '2. Price pulls back to support\n'
            '3. RSI dips to 40 (cooling off but not oversold)\n'
            '4. MACD shows bullish crossover\n'
            '5. Volume dries up on pullback\n\n'
            'All five aligning gives higher confidence. No single signal is reliable - '
            'confluence is key.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'A stock has an RSI of 82. What does technical analysis suggest?',
        options: ['Strong buy signal', 'The stock is oversold', 'The stock may be overbought and due for a pullback', 'RSI of 82 has no significance'],
        correctIndex: 2,
        explanation: 'RSI above 70 indicates overbought conditions - the stock has moved up quickly and may be due for a short-term pullback. However, strong trending stocks can remain overbought for extended periods.',
      ),
      LessonQuizQuestion(
        question: 'What defines an uptrend in technical analysis?',
        options: ['Price above its 200-day moving average', 'Series of higher highs and higher lows', 'RSI above 50', 'Volume increasing over time'],
        correctIndex: 1,
        explanation: 'An uptrend is defined by a series of higher highs and higher lows. Each rally peak exceeds the previous peak, and each pullback stays above the previous trough.',
      ),
      LessonQuizQuestion(
        question: 'Why do experienced traders look for multiple signals aligning?',
        options: ['Regulations require it', 'Single indicators generate too many false signals - confluence increases reliability', 'It is faster', 'Only amateurs use single indicators'],
        correctIndex: 1,
        explanation: 'Any single technical indicator generates many false signals. When multiple independent indicators all point in the same direction simultaneously, the probability of a successful trade increases significantly.',
      ),
    ],
  ),

  'l15': LessonContent(
    lessonId: 'l15',
    slides: [
      LessonSlide(
        title: 'What is an Option?',
        body: 'An option is a contract that gives you the RIGHT but not the '
            'OBLIGATION to buy or sell a stock at a specific price before a specific date.\n\n'
            'Two types:\n\n'
            'Call option - right to BUY shares at the strike price. '
            'You profit when the stock goes UP.\n\n'
            'Put option - right to SELL shares at the strike price. '
            'You profit when the stock goes DOWN.\n\n'
            'Key terms:\n'
            '- Strike price: the agreed buy/sell price\n'
            '- Expiration date: when the option expires\n'
            '- Premium: what you pay for the contract\n'
            '- 1 contract = 100 shares',
      ),
      LessonSlide(
        title: 'A Simple Call Option Example',
        body: 'AAPL is trading at \$180. You think it will rise to \$200 in 30 days.\n\n'
            'Option A: Buy 100 shares directly = \$18,000\n'
            'Option B: Buy 1 call option (strike \$185, 30 days) = \$300 premium\n\n'
            'If AAPL rises to \$200:\n'
            'Option A: \$20,000 value = \$2,000 gain (11% return)\n'
            'Option B: Option worth about \$1,500 = \$1,200 gain (400% return)\n\n'
            'If AAPL falls to \$170:\n'
            'Option A: \$17,000 value = \$1,000 loss (5.6%)\n'
            'Option B: Option expires worthless = \$300 loss (100%)\n\n'
            'Options offer leverage: amplified gains AND amplified losses.',
      ),
      LessonSlide(
        title: 'Put Options - Portfolio Protection',
        body: 'Put options are like insurance for your portfolio.\n\n'
            'Example: You own 100 shares of AAPL at \$180 (\$18,000 total). '
            'You are worried about a market crash.\n\n'
            'Buy 1 put option: strike \$170, expires in 3 months, premium \$400.\n\n'
            'If AAPL falls to \$140:\n'
            'Without put: portfolio worth \$14,000 - \$4,000 loss\n'
            'With put: you can sell at \$170 = \$17,000 - only \$1,000 net loss\n\n'
            'Put options act as portfolio insurance. You pay the premium '
            'whether or not you need it - just like car insurance.',
      ),
      LessonSlide(
        title: 'Options Risk Warning',
        body: 'Options are powerful tools that require serious education '
            'before using with real money.\n\n'
            'Risks beginners underestimate:\n\n'
            'Time decay (theta) - options lose value every day as expiration '
            'approaches, even if the stock does not move. '
            'Options are wasting assets.\n\n'
            'Volatility (vega) - option prices are heavily influenced by '
            'implied volatility.\n\n'
            'Leverage cuts both ways - a 50% option loss happens much faster '
            'than a 50% stock loss.\n\n'
            'For Beanstalk: understand the concepts. Do not trade real options '
            'until you have significant experience with stocks.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'What does a call option give you the right to do?',
        options: ['Sell shares at the strike price', 'Buy shares at the strike price', 'Receive dividends', 'Borrow shares'],
        correctIndex: 1,
        explanation: 'A call option gives you the right but not obligation to BUY shares at the strike price before expiration. You profit when the stock rises above the strike price plus the premium paid.',
      ),
      LessonQuizQuestion(
        question: 'You buy a put option for \$200. The stock rises strongly and your option expires worthless. What is your loss?',
        options: ['Unlimited', 'The full value of the stock', '\$200 (your premium)', 'Nothing - put options are always profitable'],
        correctIndex: 2,
        explanation: 'When you buy an option, your maximum loss is limited to the premium you paid. In this case \$200. This defined, limited risk is the key advantage of buying options over selling them.',
      ),
      LessonQuizQuestion(
        question: 'What is time decay in options?',
        options: ['Options become more valuable as expiration approaches', 'Options lose value every day as expiration approaches', 'Time decay only affects put options', 'It refers to inflation eroding premiums'],
        correctIndex: 1,
        explanation: 'Time decay (theta) means options lose value every day that passes, all else being equal. This works against option buyers and in favour of option sellers.',
      ),
    ],
  ),

  'l16': LessonContent(
    lessonId: 'l16',
    slides: [
      LessonSlide(
        title: 'What is Short Selling?',
        body: 'Short selling is betting that a stock price will FALL.\n\n'
            'Normal investing: buy low, sell high.\n'
            'Short selling: sell high, buy low (in that order).\n\n'
            'How it works:\n'
            '1. You borrow shares from your broker\n'
            '2. You sell them immediately at the current price\n'
            '3. Later, you buy them back (hopefully cheaper)\n'
            '4. Return the shares to your broker\n'
            '5. Pocket the difference\n\n'
            'Example: You short 100 shares at \$50. You receive \$5,000. '
            'Stock falls to \$30. You buy back for \$3,000. '
            'You profit \$2,000 minus borrowing costs.',
      ),
      LessonSlide(
        title: 'The Risks of Short Selling',
        body: 'Short selling is one of the riskiest strategies in investing.\n\n'
            'Unlimited loss potential: when you buy a stock, it can only fall '
            'to zero (100% loss). When you short, it can theoretically rise '
            'to infinity - your losses are unlimited.\n\n'
            'Short squeeze: if many investors are short a stock and it starts '
            'rising, they must buy to cover losses. This buying pushes the '
            'price higher, forcing more shorts to cover.\n\n'
            'GameStop in 2021 is the most famous example - rose from \$20 '
            'to \$480 in days, destroying short sellers.\n\n'
            'Borrowing costs: you pay daily fees of 20 to 50%+ annually for '
            'popular shorts.',
      ),
      LessonSlide(
        title: 'Why Short Selling Exists',
        body: 'Despite the risks, short selling serves important functions:\n\n'
            '1. Price discovery - short sellers research and expose overvalued '
            'or fraudulent companies.\n\n'
            '2. Market efficiency - shorts help prevent bubbles from inflating '
            'indefinitely.\n\n'
            '3. Hedging - fund managers short stocks to offset long positions '
            'and reduce overall portfolio risk.\n\n'
            '4. Liquidity - short sellers provide liquidity by being willing '
            'to sell when others want to buy.\n\n'
            'The most successful short sellers are often the best fundamental '
            'analysts - they dig deeper than most to find real problems.',
      ),
      LessonSlide(
        title: 'Short Interest',
        body: 'Short Interest - the percentage of a stock\'s float currently '
            'sold short.\n\n'
            'High short interest (20%+) can signal:\n'
            '- The stock is controversial or potentially overvalued\n'
            '- High short squeeze potential if the stock rises\n\n'
            'Days to Cover - short interest divided by average daily volume. '
            'How many days would it take all shorts to buy back?\n'
            'High days-to-cover = more squeeze risk.\n\n'
            'For Beanstalk users: short selling is available in virtual trading '
            'to help you understand the mechanics safely. In the real world, '
            'never short a stock unless you fully understand the risks.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'You short 100 shares at \$40. The stock rises to \$90. What is your approximate loss?',
        options: ['\$400', '\$4,000', '\$5,000', 'Unlimited theoretically, but approximately \$5,000 here'],
        correctIndex: 3,
        explanation: 'You sold at \$40 and must buy back at \$90: loss of \$50 per share x 100 shares = \$5,000. Unlike buying stocks, short selling has theoretically unlimited loss potential.',
      ),
      LessonQuizQuestion(
        question: 'What is a short squeeze?',
        options: ['When regulators force out short sellers', 'When a heavily shorted stock rises, forcing shorts to buy, driving price even higher', 'When borrowing costs become too high', 'When a company buys back its shorted shares'],
        correctIndex: 1,
        explanation: 'A short squeeze happens when a heavily shorted stock starts rising. Short sellers must buy to limit losses, but this buying pushes the price higher, forcing more shorts to cover. GameStop in 2021 is the most famous example.',
      ),
      LessonQuizQuestion(
        question: 'What is the maximum possible loss when buying a stock vs shorting a stock?',
        options: ['Same for both', '100% when buying, unlimited when shorting', 'Unlimited when buying, 100% when shorting', 'Both have unlimited loss potential'],
        correctIndex: 1,
        explanation: 'When you buy a stock, the worst case is it falls to zero - a 100% loss. When you short, it can theoretically rise forever - meaning losses are theoretically unlimited.',
      ),
    ],
  ),

  'l17': LessonContent(
    lessonId: 'l17',
    slides: [
      LessonSlide(
        title: 'What is Margin Trading?',
        body: 'Margin trading means borrowing money from your broker to buy '
            'more securities than you could with your own cash.\n\n'
            'Example:\n'
            'Your cash: \$10,000\n'
            'Broker lends you: \$10,000 (2:1 margin)\n'
            'Total buying power: \$20,000\n\n'
            'If the stock rises 20%:\n'
            'Without margin: \$10,000 x 1.20 = \$12,000 (20% return)\n'
            'With margin: \$20,000 x 1.20 = \$24,000. Repay \$10,000 loan. '
            'Net: \$14,000 (40% return on your cash)\n\n'
            'Margin amplifies both gains AND losses.',
      ),
      LessonSlide(
        title: 'Margin Calls',
        body: 'The biggest risk in margin trading: the margin call.\n\n'
            'Your broker requires you to maintain minimum equity (typically 25%). '
            'If losses eat into your equity below this level, you get a margin call - '
            'deposit more cash immediately or the broker force-sells your positions.\n\n'
            'Example gone wrong:\n'
            'You buy \$20,000 of stock on \$10,000 cash + \$10,000 loan.\n'
            'Stock falls 30% - position worth \$14,000.\n'
            'You still owe \$10,000. Your equity: \$4,000 (20% - below maintenance).\n'
            'Margin call! Broker sells immediately.\n'
            'You are left with \$4,000. Lost \$6,000 - a 60% loss on a 30% market move.',
      ),
      LessonSlide(
        title: 'Margin Interest and Costs',
        body: 'Borrowing on margin is not free. You pay interest on the borrowed '
            'amount every day.\n\n'
            'Typical margin rates: 8 to 12% annually at major brokers.\n\n'
            'Example: \$10,000 borrowed at 10% annual rate = \$1,000/year = '
            '\$2.74 per day in interest.\n\n'
            'This means your investment must return MORE than the borrowing cost '
            'just to break even. In flat markets, margin interest silently '
            'erodes your returns.\n\n'
            'Margin is designed for short-term tactical use, not buy-and-hold '
            'investing.',
      ),
      LessonSlide(
        title: 'Who Should Use Margin?',
        body: 'Margin trading is not suitable for most investors.\n\n'
            'Who might use margin:\n'
            '- Experienced traders with strict risk management\n'
            '- Investors temporarily between selling and buying assets\n'
            '- Professionals hedging specific positions\n\n'
            'Who should NOT use margin:\n'
            '- Beginners still learning market basics\n'
            '- Long-term investors in volatile assets\n'
            '- Anyone who cannot afford to lose more than their initial investment\n\n'
            'Warren Buffett: "I have seen more people fail because of liquor '
            'and leverage than for any other reason."\n\n'
            'On Beanstalk: practice with virtual margin to understand the '
            'mechanics safely.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'You invest \$5,000 cash plus \$5,000 margin. Stock falls 40%. What is your approximate loss as a percentage of your own cash?',
        options: ['40%', '60%', '80%', '100%'],
        correctIndex: 2,
        explanation: 'Position worth \$10,000 falls 40% to \$6,000. You owe \$5,000 to broker. Your equity: \$1,000. You started with \$5,000 cash - loss is \$4,000 = 80% of your own money on a 40% market move.',
      ),
      LessonQuizQuestion(
        question: 'What is a margin call?',
        options: ['A welcome call from your broker', 'A demand to deposit more funds or face forced liquidation', 'A special type of options contract', 'A limit on how much you can borrow'],
        correctIndex: 1,
        explanation: 'A margin call occurs when losses reduce your equity below the maintenance requirement. Your broker demands immediate action or will forcibly close your positions, often at the worst possible time.',
      ),
      LessonQuizQuestion(
        question: 'Why is margin interest a hidden danger for long-term investors?',
        options: ['It reduces dividends received', 'It accumulates daily and erodes returns even when the market is flat', 'It triggers automatic margin calls', 'Margin interest is tax deductible so it does not matter'],
        correctIndex: 1,
        explanation: 'Margin interest compounds daily. At 10% annual rate, \$10,000 borrowed costs about \$2.74 per day. In flat or slowly rising markets, this silently eats into returns.',
      ),
    ],
  ),

  'l18': LessonContent(
    lessonId: 'l18',
    slides: [
      LessonSlide(
        title: 'What is a Blockchain?',
        body: 'A blockchain is a decentralised digital ledger - a database that '
            'records transactions across thousands of computers simultaneously.\n\n'
            'Traditional database: one company controls it (bank, government). '
            'Centralised. Can be edited by the controller.\n\n'
            'Blockchain: thousands of computers (nodes) each hold an identical copy. '
            'No single entity controls it. Once recorded, transactions cannot '
            'be altered without changing every copy simultaneously.\n\n'
            'Each block of transactions is cryptographically linked to the '
            'previous block, creating a chain. Bitcoin was the first successful '
            'implementation in 2009.',
      ),
      LessonSlide(
        title: 'Bitcoin vs Ethereum',
        body: 'The two dominant cryptocurrencies serve very different purposes:\n\n'
            'Bitcoin (BTC):\n'
            '- Created 2009 by anonymous Satoshi Nakamoto\n'
            '- Fixed supply: 21 million coins ever\n'
            '- Purpose: digital gold and store of value\n'
            '- Simple, secure, conservative protocol\n\n'
            'Ethereum (ETH):\n'
            '- Created 2015 by Vitalik Buterin\n'
            '- No fixed supply cap\n'
            '- Purpose: programmable platform for decentralised apps\n'
            '- Powers DeFi, NFTs, and most crypto applications\n\n'
            'Simple analogy: Bitcoin is a calculator. '
            'Ethereum is a smartphone that runs apps.',
      ),
      LessonSlide(
        title: 'Wallets, Keys and Exchanges',
        body: 'How crypto works in practice:\n\n'
            'Private key - a secret password proving ownership of your crypto. '
            'If lost, your crypto is gone forever. No customer service.\n\n'
            'Public key / wallet address - your account number. '
            'Share this to receive crypto.\n\n'
            'Hot wallet - software wallet connected to internet (MetaMask). '
            'Convenient but vulnerable to hacking.\n\n'
            'Cold wallet - hardware device offline (Ledger, Trezor). '
            'Safer for large amounts.\n\n'
            'Exchange - platform to buy/sell crypto (Coinbase, Binance). '
            'They hold your keys unless you withdraw.\n\n'
            'Golden rule: "Not your keys, not your coins." '
            'If an exchange goes bankrupt (FTX 2022), your crypto may be lost.',
      ),
      LessonSlide(
        title: 'Risk, Volatility and Portfolio Sizing',
        body: 'Crypto is the most volatile major asset class in existence.\n\n'
            'Bitcoin has experienced multiple 80%+ drawdowns:\n'
            '- 2011: -94%\n'
            '- 2013 to 2015: -86%\n'
            '- 2017 to 2018: -83%\n'
            '- 2021 to 2022: -77%\n\n'
            'And multiple 10x+ recoveries from those lows.\n\n'
            'The 1 to 5% rule: most financial advisors suggest crypto should '
            'represent no more than 1 to 5% of a diversified portfolio. '
            'At 5%, even an 80% crypto crash only costs you 4% of your portfolio.\n\n'
            'Never invest money you cannot afford to lose entirely.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'What makes blockchain records nearly impossible to alter?',
        options: ['Government encryption', 'Each block is linked to the previous one and copies exist on thousands of computers', 'The technology is too new to hack', 'Blockchain companies protect the data'],
        correctIndex: 1,
        explanation: 'Blockchain security comes from cryptographic linking (each block contains a hash of the previous block) and decentralisation (thousands of identical copies exist). Altering any record would require simultaneously changing every copy.',
      ),
      LessonQuizQuestion(
        question: 'What is the key difference between Bitcoin and Ethereum?',
        options: ['Bitcoin is newer', 'Ethereum has a fixed supply of 21 million', 'Bitcoin is primarily a store of value while Ethereum is a programmable platform', 'They are identical technologies'],
        correctIndex: 2,
        explanation: 'Bitcoin was designed as digital gold - a fixed-supply store of value. Ethereum is a programmable blockchain platform that runs smart contracts and decentralised applications.',
      ),
      LessonQuizQuestion(
        question: 'What does "not your keys, not your coins" mean?',
        options: ['You should always use a hardware wallet', 'If crypto is held on an exchange you do not truly control it and risk losing it if the exchange fails', 'Private keys should be shared with trusted family', 'Crypto wallets require physical keys'],
        correctIndex: 1,
        explanation: 'If your crypto sits on an exchange, the exchange holds the private keys - not you. If the exchange is hacked or goes bankrupt (as FTX did in 2022), you may lose everything.',
      ),
    ],
  ),

  // ── l19: Budgeting Basics ─────────────────────────────────────────────────────

  'l19': LessonContent(
    lessonId: 'l19',
    slides: [
      LessonSlide(
        title: 'What is a Budget?',
        body: 'A budget is simply a plan for your money — deciding in advance where every dollar goes instead of wondering where it went.\n\n'
            'Most people think budgeting is about restriction, but it is really about intention. A budget gives you permission to spend on the things you value.\n\n'
            'Without a budget:\n'
            '- Money disappears mysteriously\n'
            '- You save whatever is left over (usually nothing)\n'
            '- Financial goals feel impossible\n\n'
            'With a budget:\n'
            '- You pay yourself first\n'
            '- You know exactly what you can spend\n'
            '- Goals become achievable with a timeline',
      ),
      LessonSlide(
        title: 'The 50/30/20 Rule',
        body: 'The simplest budgeting framework ever created:\n\n'
            '50% — Needs\n'
            'Rent, groceries, utilities, transportation, minimum debt payments. The essentials you must pay.\n\n'
            '30% — Wants\n'
            'Dining out, streaming services, clothes, hobbies, entertainment. Things that improve life but are not essential.\n\n'
            '20% — Savings & Debt\n'
            'Emergency fund, investments, retirement accounts, extra debt payments.\n\n'
            'Example on \$3,000/month take-home:\n'
            '- Needs: \$1,500\n'
            '- Wants: \$900\n'
            '- Savings: \$600\n\n'
            'Adjust the percentages to fit your situation — the framework is a starting point, not a law.',
      ),
      LessonSlide(
        title: 'Tracking Income vs Expenses',
        body: 'Before you can budget you need to know your numbers.\n\n'
            'Income: All money coming in\n'
            '- Take-home pay (after tax)\n'
            '- Side hustle / freelance income\n'
            '- Any regular transfers or allowances\n\n'
            'Fixed expenses: Same amount every month\n'
            '- Rent, car payment, phone bill, subscriptions\n\n'
            'Variable expenses: Change month to month\n'
            '- Groceries, gas, dining, clothing\n\n'
            'Pro tip: Review 3 months of bank statements to find your real spending patterns — most people underestimate their variable expenses by 30–40%.',
      ),
      LessonSlide(
        title: 'Building the Habit',
        body: 'The best budget is the one you will actually stick to.\n\n'
            'Zero-based budgeting: Every dollar gets assigned a job until income minus expenses = \$0. Nothing left unplanned.\n\n'
            'Pay yourself first: Automatically transfer savings on payday, before you can spend it.\n\n'
            'Weekly check-in: 5 minutes reviewing your spending prevents month-end surprises.\n\n'
            'Budget apps (YNAB, Mint, or even a spreadsheet) make tracking automatic.\n\n'
            'Remember: Missing your budget one month is not failure. Budgeting is a skill that improves with practice. Every expert was once a beginner.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'In the 50/30/20 budget rule, what does the "20" represent?',
        options: ['Entertainment and dining', 'Housing and transport', 'Savings and debt repayment', 'Clothing and personal care'],
        correctIndex: 2,
        explanation: 'The 20% in the 50/30/20 rule is for savings and debt repayment — building your emergency fund, investing, and paying down debt faster. This is the wealth-building slice.',
      ),
      LessonQuizQuestion(
        question: 'Your take-home pay is \$2,500/month. Using 50/30/20, how much should go to savings?',
        options: ['\$250', '\$500', '\$750', '\$1,000'],
        correctIndex: 1,
        explanation: '20% of \$2,500 = \$500. This would go toward your emergency fund, investments, or extra debt payments. Small amounts invested consistently grow significantly over time.',
      ),
      LessonQuizQuestion(
        question: 'Which of the following is a "fixed" expense?',
        options: ['Grocery shopping', 'Monthly rent payment', 'Dining out', 'Entertainment'],
        correctIndex: 1,
        explanation: 'Fixed expenses stay the same every month — rent, car payments, phone bills. Variable expenses like groceries and dining fluctuate. Knowing the difference helps you predict where you can cut back.',
      ),
    ],
  ),

  // ── l20: Credit Scores ────────────────────────────────────────────────────────

  'l20': LessonContent(
    lessonId: 'l20',
    slides: [
      LessonSlide(
        title: 'What is a Credit Score?',
        body: 'A credit score is a three-digit number (300–850) that represents how trustworthy you are as a borrower.\n\n'
            'Lenders use it to decide:\n'
            '- Whether to approve your loan or credit card\n'
            '- What interest rate to charge you\n'
            '- How much credit to extend\n\n'
            'Score ranges (FICO scale):\n'
            '800–850: Exceptional — best rates available\n'
            '740–799: Very Good — nearly as good\n'
            '670–739: Good — qualifies for most loans\n'
            '580–669: Fair — higher rates, some rejections\n'
            '300–579: Poor — very limited options\n\n'
            'A difference of 100 points can cost (or save) you tens of thousands of dollars in interest over a lifetime.',
      ),
      LessonSlide(
        title: 'How Credit Scores Are Calculated',
        body: 'Your FICO score has five ingredients:\n\n'
            '1. Payment History — 35%\n'
            'The biggest factor. Always pay on time. One missed payment can drop your score 100 points.\n\n'
            '2. Credit Utilization — 30%\n'
            'How much of your available credit you are using. Keep it below 30%. Below 10% is ideal.\n\n'
            '3. Length of Credit History — 15%\n'
            'Older accounts help. Do not close old cards you are not using.\n\n'
            '4. Credit Mix — 10%\n'
            'Having both revolving (credit cards) and installment (loans) credit helps.\n\n'
            '5. New Credit — 10%\n'
            'Applying for many accounts in a short period raises red flags.',
      ),
      LessonSlide(
        title: 'Building Credit from Zero',
        body: 'If you have no credit history, here is how to start:\n\n'
            'Secured credit card: You deposit \$200–\$500 as collateral and get a card with that limit. Use it for small purchases and pay it off every month.\n\n'
            'Become an authorized user: Ask a parent or trusted person to add you to their credit card account. Their good history can boost your score.\n\n'
            'Credit-builder loan: Some banks offer small loans specifically designed to build credit.\n\n'
            'The golden rule: Charge only what you can pay in full each month. Carrying a balance costs you interest and hurts your utilization ratio.',
      ),
      LessonSlide(
        title: 'Credit Score Myths Busted',
        body: 'Myth 1: Checking your own credit hurts your score.\n'
            'FALSE — checking your own score is a "soft inquiry" and has zero impact.\n\n'
            'Myth 2: You need to carry a balance to build credit.\n'
            'FALSE — paying in full each month is ideal. Carrying a balance just costs you interest.\n\n'
            'Myth 3: Closing old cards helps your score.\n'
            'FALSE — closing old cards reduces your available credit (hurting utilization) and shortens your history.\n\n'
            'Myth 4: Income affects your credit score.\n'
            'FALSE — income is not in your credit report. Only borrowing behavior matters.\n\n'
            'You are entitled to one free credit report per year from each of the three bureaus at AnnualCreditReport.com.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'Which factor has the biggest impact on your FICO credit score?',
        options: ['Credit mix', 'Length of credit history', 'Payment history', 'New credit inquiries'],
        correctIndex: 2,
        explanation: 'Payment history makes up 35% of your FICO score — the largest single factor. Paying on time, every time, is the single most important thing you can do for your credit.',
      ),
      LessonQuizQuestion(
        question: 'Your credit limit is \$1,000 and your balance is \$400. What is your utilization rate?',
        options: ['4%', '10%', '40%', '60%'],
        correctIndex: 2,
        explanation: 'Utilization = balance ÷ limit = \$400 ÷ \$1,000 = 40%. This is above the recommended 30% threshold. Ideally keep it under 10% for the best score impact.',
      ),
      LessonQuizQuestion(
        question: 'Which is the safest way to start building credit with no history?',
        options: ['Apply for five credit cards at once', 'Take out a large personal loan', 'Get a secured credit card and pay it off monthly', 'Ask a friend to lend you their card'],
        correctIndex: 2,
        explanation: 'A secured credit card is the safest way to build credit from scratch. You provide collateral, use it for small purchases, and pay it off each month. This builds history without the risk of debt.',
      ),
    ],
  ),

  // ── l21: Taxes 101 ────────────────────────────────────────────────────────────

  'l21': LessonContent(
    lessonId: 'l21',
    slides: [
      LessonSlide(
        title: 'How Income Tax Works',
        body: 'The US uses a progressive tax system — the more you earn, the higher percentage you pay, but only on the income above each threshold.\n\n'
            '2024 Federal brackets (single filers):\n'
            '10%: \$0 – \$11,600\n'
            '12%: \$11,601 – \$47,150\n'
            '22%: \$47,151 – \$100,525\n'
            '24%: \$100,526 – \$191,950\n\n'
            'Key insight: If you earn \$50,000, you do NOT pay 22% on all of it. You pay 10% on the first \$11,600, 12% on the next slice, and 22% only on the amount above \$47,150.\n\n'
            'Your effective tax rate (what you actually pay on average) is always lower than your marginal rate (the top bracket you reach).',
      ),
      LessonSlide(
        title: 'W-2s, 1099s and Withholding',
        body: 'Most employees receive a W-2 by January 31 each year.\n\n'
            'W-2 shows:\n'
            '- Total wages earned\n'
            '- Federal, state, and Social Security taxes already withheld\n'
            '- Employer-sponsored benefits (401k contributions, health insurance)\n\n'
            '1099 forms go to freelancers, contractors, and investors. No taxes are withheld — you are responsible for paying quarterly estimated taxes.\n\n'
            'Withholding is the tax your employer automatically deducts from each paycheck and sends to the IRS. If too much was withheld, you get a refund. Too little, and you owe.\n\n'
            'The W-4 form you fill out when starting a job tells your employer how much to withhold.',
      ),
      LessonSlide(
        title: 'Deductions and Credits',
        body: 'Deductions reduce your taxable income. Credits directly reduce your tax bill (more powerful).\n\n'
            'Standard deduction (2024):\n'
            '- Single: \$14,600\n'
            '- Married filing jointly: \$29,200\n'
            'Most people take the standard deduction rather than itemizing.\n\n'
            'Common above-the-line deductions:\n'
            '- Student loan interest (up to \$2,500)\n'
            '- Traditional IRA contributions\n'
            '- HSA contributions\n\n'
            'Common tax credits:\n'
            '- Earned Income Tax Credit (for lower-income workers)\n'
            '- Child Tax Credit\n'
            '- American Opportunity Credit (education)\n\n'
            'Investing insight: Long-term capital gains (assets held 1+ year) are taxed at 0%, 15%, or 20% — far lower than ordinary income tax rates.',
      ),
      LessonSlide(
        title: 'Filing Your Taxes',
        body: 'Tax deadline: April 15 each year (extensions available).\n\n'
            'Free filing options:\n'
            '- IRS Free File: free for income under \$79,000\n'
            '- IRS Direct File: free in participating states\n'
            '- Free fillable forms on IRS.gov\n\n'
            'What you need to file:\n'
            '- Social Security number\n'
            '- All W-2s and 1099s\n'
            '- Records of deductions\n'
            '- Prior year AGI (for e-filing)\n\n'
            'Three smart tax moves for investors:\n'
            '1. Max your 401k — contributions reduce taxable income\n'
            '2. Use a Roth IRA — pay tax now, never pay tax on growth\n'
            '3. Hold investments 1+ year for lower capital gains rates',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'You earn \$50,000. In a progressive tax system, what happens at the 22% bracket?',
        options: ['You pay 22% on all \$50,000', 'You pay 22% only on income above the 12% bracket threshold', 'You pay no tax since you are in a low bracket', 'You pay 22% on your last dollar earned only'],
        correctIndex: 1,
        explanation: 'Progressive taxation means each bracket rate applies only to the income within that range. You pay 22% only on the portion of income that falls above the 12% bracket ceiling — not on your entire income.',
      ),
      LessonQuizQuestion(
        question: 'What is the difference between a tax deduction and a tax credit?',
        options: ['They are the same thing', 'Deductions reduce taxable income; credits directly reduce taxes owed', 'Credits reduce taxable income; deductions reduce taxes owed', 'Deductions are only for businesses'],
        correctIndex: 1,
        explanation: 'A deduction reduces your taxable income (saving you a fraction of the deduction amount). A credit reduces your actual tax bill dollar-for-dollar. Credits are generally more valuable.',
      ),
      LessonQuizQuestion(
        question: 'You sell a stock after holding it for 14 months at a profit. How is this gain taxed?',
        options: ['As ordinary income (up to 37%)', 'At long-term capital gains rates (0%, 15%, or 20%)', 'It is tax-free', 'At a flat 25% rate'],
        correctIndex: 1,
        explanation: 'Gains on assets held more than one year qualify for long-term capital gains rates (0%, 15%, or 20% depending on income) — much lower than ordinary income tax rates. This is a major incentive to invest for the long term.',
      ),
    ],
  ),

  // ── l22: Emergency Funds ──────────────────────────────────────────────────────

  'l22': LessonContent(
    lessonId: 'l22',
    slides: [
      LessonSlide(
        title: 'What is an Emergency Fund?',
        body: 'An emergency fund is cash set aside specifically for unexpected, unavoidable expenses — not vacation, not a sale, not an impulse buy.\n\n'
            'True emergencies:\n'
            '- Job loss\n'
            '- Medical bills\n'
            '- Car breakdown (when you need it to work)\n'
            '- Major home repair (roof, heating)\n\n'
            'NOT emergencies:\n'
            '- Planned expenses you forgot about\n'
            '- Holiday gifts\n'
            '- New phone upgrade\n\n'
            'Without an emergency fund, any unexpected expense forces you to either take on debt (at high interest) or liquidate investments (possibly at a loss). An emergency fund is the foundation of every financial plan.',
      ),
      LessonSlide(
        title: 'How Much Do You Need?',
        body: 'The standard advice: save 3 to 6 months of essential living expenses.\n\n'
            'Essential expenses include:\n'
            '- Rent/mortgage\n'
            '- Groceries\n'
            '- Utilities\n'
            '- Minimum debt payments\n'
            '- Transportation\n\n'
            'If your monthly essentials are \$2,000, your target is \$6,000–\$12,000.\n\n'
            'Who needs more (closer to 6 months):\n'
            '- Freelancers and self-employed\n'
            '- Single-income households\n'
            '- Those in volatile industries\n\n'
            'Who may need less (closer to 3 months):\n'
            '- Dual-income stable households\n'
            '- Those with low fixed expenses\n'
            '- Those with strong job security\n\n'
            'Start with a mini emergency fund of \$1,000 if the full amount feels impossible.',
      ),
      LessonSlide(
        title: 'Where to Keep It',
        body: 'Your emergency fund has one job: be there when you need it.\n\n'
            'Requirements:\n'
            '- Instantly accessible (liquid)\n'
            '- Safe from market crashes\n'
            '- Earns something while waiting\n\n'
            'Best options:\n'
            'High-yield savings account (HYSA): Currently paying 4–5% APY. FDIC insured. Best choice for most people.\n\n'
            'Money market account: Similar to HYSA, sometimes with check-writing ability.\n\n'
            'Do NOT use:\n'
            '- Stock market (could be down when you need it)\n'
            '- CDs (locked up for months or years)\n'
            '- Under your mattress (no interest, not safe)\n\n'
            'Separate it from your regular checking account so you are not tempted to spend it.',
      ),
      LessonSlide(
        title: 'Building Your Fund',
        body: 'Building an emergency fund takes time. Here is how to make it happen:\n\n'
            'Step 1: Open a dedicated HYSA at a different bank than your checking account.\n\n'
            'Step 2: Set up an automatic transfer on payday — even \$25 or \$50 per paycheck adds up.\n\n'
            'Step 3: Direct windfalls here first — tax refund, birthday money, bonus.\n\n'
            'Step 4: Once funded, stop adding to it. Put future savings toward investments.\n\n'
            'Step 5: If you use it, replenish it before anything else.\n\n'
            'At \$200/month, you reach a \$6,000 emergency fund in 2.5 years.\n\n'
            'This single financial habit will prevent years of debt and stress.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'How many months of expenses should an emergency fund cover?',
        options: ['1 month', '2 months', '3–6 months', '12+ months'],
        correctIndex: 2,
        explanation: '3 to 6 months of essential living expenses is the widely recommended target. Freelancers and single-income households should lean toward 6 months, while stable dual-income households may be fine with 3.',
      ),
      LessonQuizQuestion(
        question: 'Where is the BEST place to keep your emergency fund?',
        options: ['Invested in index funds', 'A high-yield savings account', 'A long-term CD', 'In cash at home'],
        correctIndex: 1,
        explanation: 'A high-yield savings account (HYSA) is ideal — it is FDIC insured, instantly accessible, and currently earns 4–5% APY. Index funds are too volatile; CDs lock up your money; cash earns nothing.',
      ),
      LessonQuizQuestion(
        question: 'Your monthly essential expenses are \$1,800. What should your emergency fund target be?',
        options: ['\$900–\$1,800', '\$1,800–\$3,600', '\$5,400–\$10,800', '\$18,000+'],
        correctIndex: 2,
        explanation: '3–6 months × \$1,800 = \$5,400–\$10,800. Start with a mini goal of \$1,000, then build toward your full 3-month target, then 6-month target over time.',
      ),
    ],
  ),

  // ── l23: Compound Interest ────────────────────────────────────────────────────

  'l23': LessonContent(
    lessonId: 'l23',
    slides: [
      LessonSlide(
        title: 'Simple vs Compound Interest',
        body: 'Simple interest is calculated only on the original amount (the principal).\n\n'
            'Compound interest is calculated on the principal PLUS all previously earned interest. You earn interest on your interest.\n\n'
            'Example: \$1,000 at 10% for 3 years\n\n'
            'Simple interest:\n'
            'Year 1: \$1,000 × 10% = \$100 → total \$1,100\n'
            'Year 2: \$1,000 × 10% = \$100 → total \$1,200\n'
            'Year 3: \$1,000 × 10% = \$100 → total \$1,300\n\n'
            'Compound interest:\n'
            'Year 1: \$1,000 × 10% = \$100 → total \$1,100\n'
            'Year 2: \$1,100 × 10% = \$110 → total \$1,210\n'
            'Year 3: \$1,210 × 10% = \$121 → total \$1,331\n\n'
            'Same rate, 3 extra dollars after 3 years. Over decades? Millions of dollars difference.',
      ),
      LessonSlide(
        title: 'The Rule of 72',
        body: 'The Rule of 72 is the fastest mental math trick in investing.\n\n'
            'Divide 72 by your annual interest rate to find how many years it takes to double your money.\n\n'
            'Examples:\n'
            '- 6% return: 72 ÷ 6 = 12 years to double\n'
            '- 8% return: 72 ÷ 8 = 9 years to double\n'
            '- 10% return: 72 ÷ 10 = 7.2 years to double\n'
            '- 12% return: 72 ÷ 12 = 6 years to double\n\n'
            'S&P 500 has historically averaged ~10% annually. That means every \$1,000 invested could double to \$2,000 in about 7 years, \$4,000 in 14 years, \$8,000 in 21 years…\n\n'
            'The same rule works in reverse for debt: credit card at 24% interest? Your debt doubles in 3 years if you make no payments.',
      ),
      LessonSlide(
        title: 'Time is Your Most Valuable Asset',
        body: 'Alice starts investing \$200/month at age 22 and stops at age 32 (10 years, \$24,000 total).\n'
            'Bob starts investing \$200/month at age 32 and invests until age 65 (33 years, \$79,200 total).\n\n'
            'Assuming 8% average annual return:\n'
            'Alice at 65: ~\$602,000\n'
            'Bob at 65: ~\$352,000\n\n'
            'Alice invested less money but ended up with 70% more — simply because she started 10 years earlier.\n\n'
            'This is the power of compound interest combined with time. Every year you wait costs you far more than the money you save by waiting.\n\n'
            '"Compound interest is the eighth wonder of the world. He who understands it, earns it. He who does not, pays it." — Albert Einstein',
      ),
      LessonSlide(
        title: 'Compounding Works Against You Too',
        body: 'Compound interest is also the reason debt can feel impossible to escape.\n\n'
            'Credit card at 24% APR:\n'
            '- \$5,000 balance, minimum payments only\n'
            '- Takes 17+ years to pay off\n'
            '- You pay over \$8,000 in interest alone\n\n'
            'Student loan at 6%:\n'
            '- \$30,000 balance, 10-year repayment\n'
            '- Monthly payment: ~\$333\n'
            '- Total paid: ~\$40,000 (\$10,000 in interest)\n\n'
            'Strategy: Use compounding FOR you (invest early) while minimizing compounding AGAINST you (pay off high-interest debt fast).\n\n'
            'Rule of thumb: If debt interest rate is above 7%, pay it off before investing beyond your employer match.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'What makes compound interest different from simple interest?',
        options: ['Compound interest has a higher rate', 'Compound interest earns interest on previously earned interest', 'Simple interest grows faster over time', 'Compound interest only applies to savings accounts'],
        correctIndex: 1,
        explanation: 'Compound interest earns interest on your principal AND on all previously accumulated interest. This creates exponential growth. Simple interest only earns on the original principal, creating linear growth.',
      ),
      LessonQuizQuestion(
        question: 'Using the Rule of 72, how long to double \$5,000 at an 8% annual return?',
        options: ['4 years', '6 years', '9 years', '12 years'],
        correctIndex: 2,
        explanation: '72 ÷ 8 = 9 years. The Rule of 72 is a quick mental math trick: divide 72 by the interest rate to estimate doubling time. At 8%, your money doubles roughly every 9 years.',
      ),
      LessonQuizQuestion(
        question: 'Why does starting to invest at 22 vs 32 make such a dramatic difference?',
        options: ['Younger people get better interest rates', 'Earlier investments have more years to compound, growing exponentially', 'Tax rates are lower when you are young', 'Stock markets perform better in earlier decades'],
        correctIndex: 1,
        explanation: 'Starting earlier gives your money more compounding periods. The growth is exponential — each year of compounding adds more than the last. 10 extra years of compounding at 8% can more than double your final result.',
      ),
    ],
  ),

  // ── l24: Inflation ────────────────────────────────────────────────────────────

  'l24': LessonContent(
    lessonId: 'l24',
    slides: [
      LessonSlide(
        title: 'What is Inflation?',
        body: 'Inflation is the gradual increase in prices over time — which means your dollar buys less than it used to.\n\n'
            'Real examples:\n'
            '- A movie ticket in 1990: \$4. Today: \$15+\n'
            '- A new car in 1990: \$15,000. Today: \$48,000\n'
            '- A gallon of milk in 1990: \$1.07. Today: \$3.50+\n\n'
            'The US Federal Reserve targets 2% annual inflation as healthy for the economy. At 2% inflation:\n'
            '- \$100 today = \$98 of purchasing power in 1 year\n'
            '- \$100 today = \$82 of purchasing power in 10 years\n'
            '- \$100 today = \$45 of purchasing power in 40 years\n\n'
            'Inflation is why saving in cash long-term is a losing strategy.',
      ),
      LessonSlide(
        title: 'How Inflation is Measured',
        body: 'The most common inflation measure is the Consumer Price Index (CPI).\n\n'
            'The Bureau of Labor Statistics tracks prices of a "basket" of goods and services that average Americans buy:\n'
            '- Housing (largest weight ~33%)\n'
            '- Food and beverages\n'
            '- Transportation\n'
            '- Medical care\n'
            '- Education\n'
            '- Apparel\n\n'
            'When CPI rises 3%, it means that basket of goods costs 3% more than a year ago.\n\n'
            'Core inflation excludes food and energy (more volatile) to show underlying trends.\n\n'
            'Personal inflation may differ from CPI — if you spend heavily on rent in a city, your personal inflation could be much higher.',
      ),
      LessonSlide(
        title: 'Inflation and Your Savings',
        body: 'The silent wealth killer: if inflation runs at 3% and your savings account pays 0.5%, your money loses 2.5% of purchasing power every year.\n\n'
            '\$10,000 in a 0.5% savings account over 20 years:\n'
            '- Nominal value: ~\$11,049 (barely grew)\n'
            '- Real purchasing power (at 3% inflation): ~\$6,100 equivalent\n\n'
            'You actually lost wealth by "saving safely."\n\n'
            'Solutions:\n'
            '- High-yield savings account (HYSA): 4–5% currently beats inflation\n'
            '- I-Bonds: government bonds that adjust to inflation\n'
            '- Stock market: historically returns ~10% annually (7% after inflation)\n'
            '- Real estate: property values tend to rise with inflation\n\n'
            'The goal is to earn a real return — your return minus inflation.',
      ),
      LessonSlide(
        title: 'Why Inflation Happens',
        body: 'Inflation has several causes:\n\n'
            'Demand-pull: Too much money chasing too few goods. When the economy booms and people spend more, prices rise.\n\n'
            'Cost-push: Production costs rise (wages, materials, energy), so companies charge more.\n\n'
            'Monetary policy: When central banks print more money (quantitative easing), more dollars chase the same goods.\n\n'
            'The Fed\'s job is to balance:\n'
            '- Too low inflation (deflation risk — people delay spending)\n'
            '- Too high inflation (erodes savings, creates instability)\n\n'
            'Investing takeaway: Own assets that appreciate with inflation — stocks, real estate, commodities — rather than holding cash that loses value. Inflation is the reason "do nothing" with your money is never actually neutral.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'If inflation runs at 3% per year, what happens to \$1,000 kept in a 0% savings account over 10 years?',
        options: ['It stays worth \$1,000', 'It grows in value', 'Its purchasing power shrinks to about \$744', 'It loses all value'],
        correctIndex: 2,
        explanation: 'At 3% annual inflation over 10 years, \$1,000 loses about 26% of its purchasing power (\$1,000 × 0.97^10 ≈ \$737). The number stays the same but it buys significantly less.',
      ),
      LessonQuizQuestion(
        question: 'What does the Consumer Price Index (CPI) measure?',
        options: ['Stock market performance', 'The average price change of a basket of goods and services', 'Government spending levels', 'Corporate profit margins'],
        correctIndex: 1,
        explanation: 'The CPI tracks the average price change over time for a basket of goods and services that US consumers typically buy — housing, food, transport, healthcare, etc. It is the primary inflation measure.',
      ),
      LessonQuizQuestion(
        question: 'What is "real return" on an investment?',
        options: ['The return in dollars', 'The guaranteed return', 'The return after subtracting inflation', 'The pre-tax return'],
        correctIndex: 2,
        explanation: 'Real return = nominal return − inflation rate. If stocks return 10% and inflation is 3%, your real return is 7%. This is what actually matters for wealth — how much more you can buy, not just how many dollars you have.',
      ),
    ],
  ),

  // ── l25: Banking Basics ───────────────────────────────────────────────────────

  'l25': LessonContent(
    lessonId: 'l25',
    slides: [
      LessonSlide(
        title: 'Checking vs Savings Accounts',
        body: 'These are the two core bank accounts everyone should have.\n\n'
            'Checking account — your everyday spending hub\n'
            '- No limit on transactions\n'
            '- Comes with a debit card\n'
            '- Very low (often 0%) interest\n'
            '- Used for: bills, groceries, rent, paycheck deposits\n\n'
            'Savings account — where money waits\n'
            '- Designed for money you do not need immediately\n'
            '- Earns interest (traditionally low, but HYSAs pay 4–5%)\n'
            '- Limited to 6 withdrawals/transfers per month\n'
            '- Used for: emergency fund, saving for a goal\n\n'
            'Rule: Keep 1–2 months of expenses in checking for bills, the rest in a high-yield savings account earning interest.',
      ),
      LessonSlide(
        title: 'APY and How Banks Pay You',
        body: 'APY stands for Annual Percentage Yield — the actual return you earn on savings in a year, accounting for compound interest.\n\n'
            'APR (Annual Percentage Rate) is the rate without compounding. Banks advertise APY for savings (sounds higher) and APR for loans (sounds lower). Know the difference.\n\n'
            'How a HYSA at 4.5% APY works:\n'
            '- \$5,000 deposited\n'
            '- Earns \$225 in year 1\n'
            '- Balance: \$5,225, which earns even more in year 2\n\n'
            'Traditional banks offer 0.01–0.5% APY. Online banks and HYSAs offer 4–5%. For a \$10,000 balance, that difference is \$400–\$500 per year for doing nothing.\n\n'
            'FDIC insurance protects up to \$250,000 per depositor per bank. Your money is safe even if the bank fails.',
      ),
      LessonSlide(
        title: 'Bank Fees to Avoid',
        body: 'Banks make billions from fees. Here is what to watch for:\n\n'
            'Monthly maintenance fee: \$10–\$15/month. Open a free checking account or meet minimum balance requirements to waive.\n\n'
            'Overdraft fee: \$25–\$35 per transaction when you spend more than your balance. Enable low-balance alerts. Many banks now offer no-fee overdraft protection.\n\n'
            'ATM fees: Using out-of-network ATMs can cost \$3–\$5 per transaction. Use your bank\'s network or an account that reimburses fees.\n\n'
            'Wire transfer fees: \$20–\$45 for outgoing wires. Use ACH transfers (free but slower) when not urgent.\n\n'
            'Minimum balance fee: Some accounts charge if your balance drops below a threshold.\n\n'
            'Best move: A free checking account at an online bank, with a HYSA at a separate online bank for savings.',
      ),
      LessonSlide(
        title: 'Types of Financial Institutions',
        body: 'Not all banks are the same:\n\n'
            'Traditional banks (Chase, Bank of America, Wells Fargo)\n'
            '- Large branch networks\n'
            '- Convenient but often lower rates and more fees\n\n'
            'Credit unions\n'
            '- Member-owned, not-for-profit\n'
            '- Often better rates and fewer fees\n'
            '- More community-focused\n'
            '- Must qualify for membership (employer, region, etc.)\n\n'
            'Online banks (Ally, Marcus, SoFi, Capital One 360)\n'
            '- No physical branches\n'
            '- Lowest overhead = highest savings rates\n'
            '- Best for HYSAs\n\n'
            'Rule of thumb: Use a big bank for in-person needs and convenience, an online bank\'s HYSA for your savings.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'What is the main difference between a checking and savings account?',
        options: ['Savings accounts have no fees', 'Checking accounts earn more interest', 'Checking is for daily transactions; savings is for storing money and earning interest', 'They are identical products'],
        correctIndex: 2,
        explanation: 'Checking accounts are transaction accounts — unlimited deposits and withdrawals, great for daily use. Savings accounts limit withdrawals and are designed for storing money you want to grow with interest.',
      ),
      LessonQuizQuestion(
        question: 'A HYSA offers 4.5% APY. How much does \$8,000 earn in one year?',
        options: ['\$45', '\$360', '\$450', '\$800'],
        correctIndex: 1,
        explanation: '\$8,000 × 4.5% = \$360 per year in interest. Compare this to a traditional savings account at 0.01% (\$0.80) — the same \$8,000 earns 450× more in a HYSA for zero extra effort.',
      ),
      LessonQuizQuestion(
        question: 'FDIC insurance protects bank accounts up to how much?',
        options: ['\$50,000', '\$100,000', '\$250,000', 'Unlimited'],
        correctIndex: 2,
        explanation: 'FDIC insurance covers up to \$250,000 per depositor per bank. This means if your bank fails, your deposits up to \$250,000 are fully protected by the federal government.',
      ),
    ],
  ),

  // ── l26: Student Loans ────────────────────────────────────────────────────────

  'l26': LessonContent(
    lessonId: 'l26',
    slides: [
      LessonSlide(
        title: 'Types of Student Loans',
        body: 'Not all student loans are equal. Understanding the difference can save you thousands.\n\n'
            'Federal loans (from the US government):\n'
            '- Fixed interest rates set by Congress\n'
            '- Multiple repayment plans including income-driven options\n'
            '- Access to forgiveness programs\n'
            '- No credit check for most undergraduate loans\n\n'
            'Types of federal loans:\n'
            '- Direct Subsidized: Government pays interest while you\'re in school\n'
            '- Direct Unsubsidized: Interest accrues from day one\n'
            '- PLUS Loans: For grad students or parents. Higher rates.\n\n'
            'Private loans (from banks and lenders):\n'
            '- Variable or fixed rates based on credit score\n'
            '- No income-driven repayment options\n'
            '- No forgiveness programs\n'
            '- Use only as a last resort after maxing federal options.',
      ),
      LessonSlide(
        title: 'How Interest Accrues',
        body: 'Student loan interest is what turns a manageable debt into an overwhelming one if ignored.\n\n'
            'On an unsubsidized loan of \$10,000 at 6.5%:\n'
            '- Daily interest: \$10,000 × 6.5% ÷ 365 = \$1.78/day\n'
            '- Monthly interest: ~\$54/month\n'
            '- If you defer for 4 years in college, you add ~\$2,600 in interest\n'
            '- Your \$10,000 loan is now \$12,600 before you make one payment\n\n'
            'Capitalization: When deferred interest gets added to your principal, you then pay interest on that interest. This is compound interest working against you.\n\n'
            'Smart move: Make interest-only payments while in school, even \$20–\$50/month, to prevent capitalization.',
      ),
      LessonSlide(
        title: 'Repayment Plans',
        body: 'Federal loans offer flexible repayment options:\n\n'
            'Standard (10-year): Fixed payments, least total interest. Best if you can afford it.\n\n'
            'Graduated: Low payments now that increase every 2 years. Good for careers with rising income.\n\n'
            'Income-Driven Repayment (IDR): Payment capped at 10% of discretionary income. Remaining balance forgiven after 20–25 years.\n\n'
            'SAVE Plan (newest): Most generous IDR plan. Payments as low as 5% of discretionary income for undergrad loans. Balance forgiven after 10 years if original balance was ≤\$12,000.\n\n'
            'Public Service Loan Forgiveness (PSLF): Work for government or non-profit for 10 years + 120 payments = full forgiveness.\n\n'
            'Key rule: Never miss a payment. Late payments damage your credit and can trigger default.',
      ),
      LessonSlide(
        title: 'Borrowing Smart',
        body: 'The student loan decisions you make at 18 affect your finances at 30. Here is how to borrow wisely:\n\n'
            'Only borrow what you need. Calculate tuition + housing − grants − scholarships − family contribution. Borrow the difference, not the maximum offered.\n\n'
            '"Borrow no more than your expected first-year salary." If you expect to earn \$45,000, keep total loans under \$45,000.\n\n'
            'Exhaust free money first:\n'
            '1. Scholarships and grants (free)\n'
            '2. Work-study programs\n'
            '3. Federal subsidized loans\n'
            '4. Federal unsubsidized loans\n'
            '5. Private loans (last resort)\n\n'
            'The True Cost Calculator: A \$50,000 loan at 6.5% on the standard 10-year plan costs you \$68,000 total. Every \$10,000 you can avoid borrowing saves roughly \$13,600.',
      ),
    ],
    quiz: [
      LessonQuizQuestion(
        question: 'What is the key advantage of federal student loans over private loans?',
        options: ['Federal loans have no interest', 'Federal loans offer income-driven repayment and forgiveness options; private loans do not', 'Private loans are always cheaper', 'Federal loans require no repayment'],
        correctIndex: 1,
        explanation: 'Federal loans offer protections private loans do not: income-driven repayment plans (payments based on what you earn), deferment options, and forgiveness programs like PSLF. Private loans are inflexible and should only be used after maxing federal options.',
      ),
      LessonQuizQuestion(
        question: 'On an unsubsidized loan, what happens to interest while you are in school and not making payments?',
        options: ['Interest is paused during school', 'The government pays the interest', 'Interest accrues and capitalizes, increasing your total balance', 'The rate drops to 0%'],
        correctIndex: 2,
        explanation: 'On unsubsidized loans, interest accrues from the day the loan is disbursed — even while you are in school. When you enter repayment, that unpaid interest capitalizes (gets added to your principal). Making interest-only payments in school prevents this.',
      ),
      LessonQuizQuestion(
        question: 'What is the general rule of thumb for maximum student loan borrowing?',
        options: ['Borrow as much as offered', 'Borrow no more than your expected starting salary', 'Borrow at least \$100,000 for any degree', 'Borrowing amount has no impact on future finances'],
        correctIndex: 1,
        explanation: 'A common guideline is to borrow no more than your expected first-year salary in total student loans. If you expect to earn \$40,000, keep loans under \$40,000. This keeps monthly payments manageable on the standard 10-year plan.',
      ),
    ],
  ),

};
