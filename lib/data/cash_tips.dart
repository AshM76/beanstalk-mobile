/// All dialogue for Cash — the Beanstalk investing guide character.
class CashTips {
  CashTips._();

  // ── Lesson slide tips ────────────────────────────────────────────────────────
  // Indexed by lessonId → [slide 0 tip, slide 1 tip, slide 2 tip, slide 3 tip]
  // Tips are specific to each lesson topic.

  static const Map<String, List<String>> _slideTips = {
    'l1': [
      "Think of a stock like owning a tiny slice of pizza 🍕 The bigger the company, the more slices there are!",
      "Companies sell stock to raise money for growth — you become a part-owner, not just a customer!",
      "Stock prices change every second based on what buyers and sellers agree on. It's like an auction that never stops! 🔔",
      "You profit two ways: sell the stock for more than you paid, OR collect dividends if the company shares profits. Sweet deal! 🍬",
    ],
    'l2': [
      "Stock exchanges are like giant digital bazaars open Monday–Friday. No weekend shopping for stocks! 🛒",
      "Every trade needs a willing buyer AND seller at the same price. No agreement = no trade! 🤝",
      "U.S. markets run 9:30 AM – 4:00 PM Eastern. Miss that window and you'll have to wait until tomorrow!",
      "Millions of trades fire every second at peak hours. The market is basically a very fast, very nerdy auction house. ⚡",
    ],
    'l3': [
      "Charts are like a stock's heartbeat monitor — they show where prices have been, which hints at where they might go! 💓",
      "Green candles = price went UP that period. Red candles = price went DOWN. Simple as traffic lights! 🚦",
      "Volume bars at the bottom show how much was traded. High volume on a big move = traders really mean it!",
      "Patterns like 'head and shoulders' sound strange but are just shapes traders watch for to predict direction. 📐",
    ],
    'l4': [
      "The bid is the highest price a buyer will pay. The ask is the lowest price a seller will accept. The gap between them is the spread! 📏",
      "A tight spread (small gap) means the stock is very liquid — easy to buy or sell quickly. Wide spreads = trickier to trade.",
      "Market makers sit between buyers and sellers like referees, keeping trading smooth. They profit from that tiny spread.",
      "Limit orders let you name your price. Market orders say 'fill me NOW at whatever the current price is.' Each has its place!",
    ],
    'l5': [
      "Don't put all your eggs in one basket! If that basket drops, ALL your eggs crack. Diversification = multiple baskets! 🥚",
      "If your tech stocks tank but healthcare stocks rise, you don't lose everything. That's diversification working its magic!",
      "Spreading across sectors, countries, and asset types reduces risk without killing your returns. Best of both worlds! 🌍",
      "Studies show just 15–20 different stocks capture most of diversification's risk-reduction benefits. You don't need hundreds! 🎯",
    ],
    'l6': [
      "Higher potential return ALWAYS comes with higher risk. There's no such thing as a free lunch on Wall Street! 🍔",
      "Bonds are like slow trains — steady but won't make you rich quick. Stocks are fast cars — thrilling but bumpier! 🚗",
      "Your 'risk tolerance' is simply how well you sleep at night when your portfolio drops 20%. Know yours — it matters!",
      "The good news: over long time horizons, stocks have beaten almost every other asset class historically. Time is your superpower! ⏰",
    ],
    'l7': [
      "Asset allocation is deciding how to divide your money between stocks, bonds, cash, and other assets. The recipe matters! 🗂️",
      "Classic rule of thumb: subtract your age from 110 to get your stock percentage. At age 20? Aim for ~90% stocks!",
      "Rebalancing means selling some winners and buying more laggards to stay on target. Boring? Yes. Smart? Absolutely!",
      "Target-date funds do all the heavy lifting — they automatically shift from risky to safe as you approach retirement. 🎯",
    ],
    'l8': [
      "An ETF is like a pre-packed shopping basket of many stocks — buy the whole basket with one click! 🧺",
      "ETFs trade on exchanges like regular stocks. Mutual funds price once daily after market close. Different tools!",
      "Expense ratios matter more than most people think. 1% vs 0.05% over 30 years can cost you tens of thousands in lost returns! 💸",
      "Index ETFs (like SPY or QQQ) track the whole market — and most professional fund managers can't even beat them! 🏆",
    ],
    'l9': [
      "You don't need to be a landlord to invest in real estate! REITs and crowdfunding let you in with way less cash. 🏠",
      "Real estate benefits stack up: rental income + property appreciation + tax write-offs. Triple threat! 💪",
      "Location, location, location! The same house in different neighborhoods can be worth completely different amounts.",
      "Real estate is generally LESS volatile than stocks, but needs more upfront capital to get started. ⚖️",
    ],
    'l10': [
      "REITs let you own a slice of skyscrapers, shopping malls, or hospitals — without buying the whole building! 🏢",
      "By law, REITs must distribute 90% of taxable income as dividends. Great for income investors who love cash flow! 💰",
      "Commercial real estate spans offices, retail, industrial, healthcare — all with different risk and return profiles.",
      "REITs often move differently from stocks, making them a solid diversifier for your overall portfolio. 📊",
    ],
    'l11': [
      "Dollar-cost averaging = investing a fixed amount regularly (e.g., \$50/week) regardless of what the market is doing. 📅",
      "When prices are LOW, your fixed amount buys MORE shares. When prices are HIGH, it buys fewer. Automatic smart investing!",
      "DCA removes the impossible 'should I invest today?' question. Just invest every payday and let time handle the rest!",
      "Consistent DCA investors often outperform those who try to time the market. The secret? Just start and stay consistent. 🚀",
    ],
    'l12': [
      "Value investors hunt for bargains — stocks trading below their true worth. Growth investors chase tomorrow's winners! 🔍",
      "Warren Buffett, the greatest investor alive, built his fortune on value investing — great companies at fair prices.",
      "Growth stocks have high P/E ratios because investors pay for FUTURE earnings, not today's profits. It's all about potential! 🌱",
      "Neither style always wins — the best portfolios often blend BOTH value AND growth stocks for balance. ⚖️",
    ],
    'l13': [
      "Dividends are cash payments companies make to shareholders — like getting a bonus just for holding the stock! 💰",
      "Dividend yield = annual dividend ÷ stock price. A 4% yield on a \$100 stock pays you \$4 per year, per share.",
      "Dividend reinvestment (DRIP) uses your payouts to automatically buy more shares. Small snowball, big avalanche! ☃️",
      "Blue-chip dividend stocks like Coca-Cola have paid dividends every single year for 60+ years. That's reliability! ✅",
    ],
    'l14': [
      "Technical analysts believe past price patterns can hint at future moves. It's chart reading as an actual skill! 📉",
      "Support levels act like floors — prices tend to bounce back up from them. Resistance levels act like ceilings!",
      "Moving averages smooth out the noise and show you the actual trend direction. The 50-day MA is a classic reference.",
      "RSI (Relative Strength Index) tells you if a stock is overbought (>70, maybe due for a pullback) or oversold (<30, maybe a bargain)! 🎯",
    ],
    'l15': [
      "Options give you the RIGHT (but not the obligation) to buy or sell at a fixed price. They're powerful tools! 🎯",
      "CALL option = you're betting the stock goes UP. PUT option = you're betting it goes DOWN. Know the difference!",
      "Options expire on a set date. As time passes, the option loses value — called 'theta decay'. Time is literally money here! ⏰",
      "Options can protect your portfolio like insurance, or amplify your gains. With great leverage comes great responsibility! ⚡",
    ],
    'l16': [
      "Short selling means BORROWING shares, selling them, then hoping to buy them back cheaper later. Profit = the difference! 📉",
      "Normal investing: your max loss is what you paid. Short selling: losses are theoretically UNLIMITED if the price keeps rising! ⚠️",
      "The GameStop squeeze of 2021 showed the world what happens when millions of retail investors squeeze a heavily shorted stock. 🎮",
      "Short selling serves a real purpose — it helps expose overvalued companies and keeps markets honest in the long run.",
    ],
    'l17': [
      "Margin trading lets you borrow from your broker to invest MORE than you actually have. That's leverage! ⚡",
      "Leverage cuts both ways — 2x leverage means 2x profits when right, but 2x losses when wrong. Double-edged sword!",
      "A 'margin call' happens when losses get too big and your broker demands more cash immediately. Very stressful! ⚠️",
      "Always make sure your investment returns exceed your borrowing costs. Do the math BEFORE borrowing. 🔢",
    ],
    'l18': [
      "Crypto is digital currency secured by cryptography — no banks, no governments. It's decentralized money! 🪙",
      "Bitcoin launched in 2009 by the mysterious Satoshi Nakamoto. Still the largest crypto by market cap after all these years!",
      "The blockchain is a permanent, public record of every transaction. Transparent but pseudonymous — your address, not your name.",
      "Crypto is extremely volatile — Bitcoin has dropped 80%+ from its peak... multiple times. Handle with care! 🎢",
    ],
    'l19': [
      "People don't plan to fail — they fail to plan. A budget is just a spending plan. Takes 20 minutes to set up, lasts a lifetime! 💵",
      "50% needs, 30% wants, 20% savings — the 50/30/20 rule is flexible. It's a guide, not a straitjacket!",
      "Check your last 3 bank statements. I bet you find at least one subscription you forgot about. Cancel it today! 💸",
      "Automate your savings like you automate your bills. If it never hits your checking account, you can't spend it. Genius!",
    ],
    'l20': [
      "Your credit score is your financial GPA. It follows you everywhere — apartments, car loans, even some job applications! 💳",
      "Payment history is 35% of your score. One missed payment can drop your score 100 points. Set up autopay NOW.",
      "A secured credit card is like training wheels for credit. Use it for gas or groceries, pay it off monthly. Build that score! 🏗️",
      "Fun fact: Checking your OWN credit score never hurts your score. Only hard inquiries from lenders do. Check freely! ✅",
    ],
    'l21': [
      "Taxes are not a mystery — they are just math. And once you understand the brackets, you stop fearing April 15! 🧾",
      "You get a W-2 if you're an employee, a 1099 if you're a contractor. Different forms, same goal: tell the IRS what you earned.",
      "A deduction saves you a fraction of its value. A credit saves you dollar-for-dollar. Always hunt for credits first! 🎯",
      "The Roth IRA is one of the greatest tax inventions ever. Pay tax once now — never pay tax on the growth. Future you says thanks! 🙌",
    ],
    'l22': [
      "An emergency fund is not an 'it would be nice' fund. It's the financial foundation everything else is built on! 🛡️",
      "3–6 months sounds like a lot. Break it down: saving \$200/month gets you to \$2,400 in a year. One emergency at a time!",
      "Your emergency fund belongs in a high-yield savings account, NOT the stock market. You might need it when stocks are down 30%!",
      "Once you use your emergency fund — no shame, that's what it's for! — replenish it before anything else. Always rebuild first.",
    ],
    'l23': [
      "Compound interest is just returns earning returns. But over decades, it turns small seeds into massive trees! ✨",
      "Rule of 72: divide 72 by your interest rate to see how fast your money doubles. At 8%? Every 9 years. Wild, right? 🧮",
      "Alice vs Bob proves it: starting 10 years earlier with LESS money beats starting later with more. Time is the real secret weapon!",
      "Compound interest works FOR you in investments and AGAINST you in debt. Pick your side wisely. Be on the earning side! 🌱",
    ],
    'l24': [
      "Inflation is like a slow leak in your savings. You can't hear it, but over years it deflates your purchasing power! 📉",
      "CPI tracks a basket of everyday goods. When CPI goes up 3%, life costs 3% more. Your savings need to beat that number.",
      "Leaving \$10,000 in a 0.5% account for 20 years while inflation runs at 3%? You actually LOST wealth. Mind-bending, right?",
      "Stocks, real estate, I-Bonds — these fight inflation. Cash savings at low rates surrender to it. Choose your allies wisely! ⚔️",
    ],
    'l25': [
      "Checking is for spending, savings is for growing. Keep them separate at different banks so savings is out of temptation's reach! 🏦",
      "A high-yield savings account at 4.5% vs a traditional bank at 0.01%? On \$10,000 that's \$449 vs \$1 per year. Same effort! 💰",
      "Bank fees are sneaky. Monthly fees, overdraft fees, ATM fees — they add up to hundreds per year. Switch to a free account! 🚫",
      "Credit unions are the underrated gems of banking — member-owned, fewer fees, often better rates. Worth looking into!",
    ],
    'l26': [
      "Federal loans first, always. Private loans are last resort — they have no income-driven plans, no forgiveness. Dangerous if overdone! 🎓",
      "Interest accruing while you're in school is sneaky. Even \$30/month in interest payments prevents thousands in capitalization later.",
      "Income-driven repayment ties your payment to what you earn. Struggling to find work? Your payment goes down. Safety net! 🛡️",
      "The golden rule: borrow no more than your expected starting salary. If it's a \$45k job, aim for under \$45k in total debt.",
    ],
  };

  // ── Quiz hints (shown before answering — thinking mood) ──────────────────────

  static const Map<String, List<String>> _quizHints = {
    'l1': [
      "Think about what it means to actually OWN a piece of a company...",
      "This one's about why companies decide to go public and sell shares in the first place.",
      "What forces drive prices up or down? Think about buyers, sellers, and information.",
    ],
    'l2': [
      "Where do millions of buyers and sellers come together each day to trade?",
      "Think about what 'market hours' means — when is the NYSE actually open?",
      "What connects buyers who want a stock with sellers who have it?",
    ],
    'l3': [
      "What does each 'candle' on a candlestick chart actually represent?",
      "Think about what the bars at the bottom of a chart (volume) are telling you.",
      "Which pattern signals that a stock might be about to reverse direction?",
    ],
    'l4': [
      "The spread is the difference between two prices — which two prices exactly?",
      "Think about what 'liquidity' means for ease of trading a stock.",
      "Which order type gives you control over the exact price you pay?",
    ],
    'l5': [
      "The key word here is 'spreading' — spreading what, exactly?",
      "Think about what happens to your portfolio if you own only one type of asset.",
      "How many stocks do most experts suggest for adequate diversification?",
    ],
    'l6': [
      "Think about the relationship between potential reward and the risk you take on.",
      "Compare bonds and stocks — which is generally more volatile?",
      "What's the most important factor that determines how much risk you should take?",
    ],
    'l7': [
      "Asset allocation is about splitting money between different types of investments. What are those types?",
      "Think about how your time horizon affects how aggressive your allocation should be.",
      "What does 'rebalancing' mean and why might you need to do it?",
    ],
    'l8': [
      "An ETF tracks something — what does it track exactly?",
      "Think about the key difference between how ETFs and mutual funds trade.",
      "Which type of ETF tends to have the lowest expense ratios?",
    ],
    'l9': [
      "You don't need to buy a whole property to invest in real estate. What other options exist?",
      "Think about the multiple ways real estate can generate returns for an investor.",
      "What's the most commonly cited factor in determining real estate value?",
    ],
    'l10': [
      "What does REIT stand for and what do they invest in?",
      "REITs are known for something special with their dividends — what's the legal requirement?",
      "How do REITs help a stock-heavy portfolio?",
    ],
    'l11': [
      "DCA is a strategy about consistent investing. What makes it 'automatic'?",
      "Think about what happens when you invest a fixed amount when prices are LOW vs HIGH.",
      "What does DCA eliminate that most investors struggle with?",
    ],
    'l12': [
      "Value investing and growth investing are both strategies — how do they differ in approach?",
      "Think about what P/E ratio actually measures about a stock.",
      "Which famous investor is most closely associated with value investing?",
    ],
    'l13': [
      "What exactly is a dividend and who pays it to you?",
      "How do you calculate dividend yield from the annual payment and stock price?",
      "What happens to your share count when you reinvest dividends automatically?",
    ],
    'l14': [
      "Technical analysis uses price charts — what does it NOT look at (that fundamental analysis does)?",
      "Think about what 'support' and 'resistance' mean for price movement.",
      "RSI tells you about momentum — what does a very high RSI score suggest?",
    ],
    'l15': [
      "An option is a contract that gives you a RIGHT. What's the difference between a right and an obligation?",
      "If you own a CALL option, in what direction are you hoping the stock moves?",
      "What happens to an option's value as it gets closer to its expiration date?",
    ],
    'l16': [
      "Short selling is the opposite of normal 'buy low, sell high.' How does the order of operations differ?",
      "Think about what happens to your loss if you short a stock and the price KEEPS rising.",
      "Short sellers serve a function in markets — what information do they bring?",
    ],
    'l17': [
      "Margin trading uses borrowed money. What do you put up as collateral to borrow?",
      "If leverage amplifies gains, what else does it amplify equally?",
      "A 'margin call' is a stressful event — what triggers one?",
    ],
    'l18': [
      "Blockchain is crypto's backbone — what makes it different from a regular database?",
      "Which cryptocurrency was the first ever created and who invented it?",
      "Crypto is known for extreme price swings — what term describes this characteristic?",
    ],
    'l19': [
      "The 50/30/20 rule splits income three ways — which bucket is specifically for building wealth?",
      "Think about 20% of \$2,500 — that's your wealth-building slice for the month.",
      "Fixed vs variable — which type of expense stays the same every month no matter what?",
    ],
    'l20': [
      "Five factors make up your credit score — which one carries the most weight?",
      "Utilization = balance divided by credit limit. What percentage is considered healthy?",
      "For someone with no credit history, what is the safest first step to build credit?",
    ],
    'l21': [
      "In a progressive tax system, does your highest bracket rate apply to ALL your income?",
      "Think about what you receive from an employer at tax time showing your wages and withholding.",
      "You sell a stock after 14 months for a profit. Which tax rate applies?",
    ],
    'l22': [
      "The rule of thumb is 3–6 months of a specific type of expense — which type?",
      "Where should an emergency fund be kept — invested, in a HYSA, or under the mattress?",
      "Calculate: monthly expenses of \$1,800 × 3 months minimum = ?",
    ],
    'l23': [
      "What is the core mechanic that makes compound interest grow exponentially?",
      "Using Rule of 72 — at 8% annual return, how many years to double your money?",
      "Alice started investing 10 years before Bob. Why did she end up with more money despite investing less total?",
    ],
    'l24': [
      "If inflation is 3% and your savings account pays 0%, what is your real return?",
      "What is the name of the index that measures US inflation by tracking a basket of goods?",
      "Your nominal return is 10%, inflation is 3%. What is your real return?",
    ],
    'l25': [
      "Which account is designed for everyday spending and has unlimited transactions?",
      "Calculate 4.5% APY on \$8,000 — what do you earn in one year?",
      "What is the FDIC insurance limit per depositor per bank?",
    ],
    'l26': [
      "What key feature separates federal student loans from private loans?",
      "On an unsubsidized loan, interest accrues while in school. What happens to that unpaid interest when repayment starts?",
      "What is the widely recommended maximum you should borrow for your education?",
    ],
  };

  // ── Correct answer reactions (per lesson topic) ──────────────────────────────

  static const Map<String, String> _correctMessages = {
    'l1': "Nailed it! You've got the stock basics locked down! 🎉",
    'l2': "Perfect! You understand how the market machinery works! 🏛️",
    'l3': "Chart master in training! That's exactly right! 📊",
    'l4': "Spot on! Bid/ask dynamics are tricky and you got it! 💱",
    'l5': "Yes! Diversification is your portfolio's seatbelt. Nailed it! 🥧",
    'l6': "Exactly! Risk and return are two sides of the same coin. 💪",
    'l7': "Right on! Asset allocation is the foundation of a solid portfolio! 🗂️",
    'l8': "Nailed it! ETF knowledge is power — and you've got it! 🧺",
    'l9': "Correct! Real estate investing isn't just for the wealthy. You get it! 🏠",
    'l10': "Great answer! REITs are a fantastic tool and you understand them! 🏢",
    'l11': "Perfect! DCA is simple and powerful — and you've got it! 📅",
    'l12': "Exactly right! Value vs growth is a fundamental distinction. 🔍",
    'l13': "Yes! Dividends are one of the best passive income tools. You nailed it! 💰",
    'l14': "Chart reading skills unlocked! That answer was spot on! 📉",
    'l15': "Options mastered! That's a complex concept and you nailed it! 🎯",
    'l16': "Exactly! Short selling is tricky and you understand the mechanics! 📉",
    'l17': "Right! Margin trading is powerful and risky — and you get it! ⚡",
    'l18': "Crypto knowledge level up! That's exactly right! 🪙",
    'l19': "Budget boss! You understand how the 50/30/20 rule works. Time to build that plan! 💵",
    'l20': "Credit score mastered! That knowledge is worth thousands of dollars in better rates. 💳",
    'l21': "Tax savvy! Understanding how taxes work puts you ahead of most adults. 🧾",
    'l22': "Emergency fund wisdom unlocked! This single habit prevents years of financial stress. 🛡️",
    'l23': "Compound interest cracked! You now understand the most powerful force in personal finance. ✨",
    'l24': "Inflation understood! Knowing this will change how you think about savings forever. 📉",
    'l25': "Banking basics nailed! Now you know where to park your money to make it work. 🏦",
    'l26': "Student loan smart! This knowledge could save you tens of thousands. Borrow wisely! 🎓",
  };

  // ── Wrong answer encouragements (per lesson topic) ───────────────────────────

  static const Map<String, String> _wrongMessages = {
    'l1': "Close! This one trips a lot of people up. Read the explanation — stocks are simpler than they seem! 🌱",
    'l2': "Not quite! Market mechanics are fascinating once they click. Give the explanation a read!",
    'l3': "Chart reading takes practice! Check the explanation and you'll see it clearly next time. 📊",
    'l4': "Tricky one! Bid/ask spreads confuse even experienced traders at first. The explanation will clear it up!",
    'l5': "Almost! Diversification is intuitive once you see it from the right angle. Check the explanation! 🥧",
    'l6': "Not this time! The risk/return relationship is subtle. Read the explanation — it'll stick! ⚖️",
    'l7': "Close! Asset allocation can be nuanced. The explanation breaks it down really well!",
    'l8': "Not quite! ETF mechanics catch people off guard. The explanation's got you covered! 🧺",
    'l9': "Almost! Real estate investing has some surprising twists. Check the explanation!",
    'l10': "Not this time, but REITs are genuinely complex. Read the explanation — it's worth it! 🏢",
    'l11': "Close! DCA seems simple but the details matter. The explanation clears it right up! 📅",
    'l12': "Almost! Value vs growth is a classic debate. Read the explanation for the full picture! 🔍",
    'l13': "Not quite! Dividend math trips people up. The explanation makes it crystal clear! 💰",
    'l14': "Chart analysis takes time to master! Read the explanation — this concept will click! 📉",
    'l15': "Options are tricky! Even pros get confused at first. Read the explanation carefully! 🎯",
    'l16': "Short selling is counterintuitive — don't worry! Read the explanation and it'll make sense! 📉",
    'l17': "Margin mechanics are subtle. Read the explanation — understanding this could save you money! ⚡",
    'l18': "Crypto is complex! Read the explanation — this one matters for understanding the whole space. 🪙",
    'l19': "Almost! Budgeting rules have specific meanings. Read the explanation — it'll stick! 💵",
    'l20': "Not this time! Credit scores have a specific formula. Read the explanation to master it. 💳",
    'l21': "Tax rules trip everyone up at first! Read the explanation — this will save you money. 🧾",
    'l22': "Close! Emergency fund rules have specific numbers behind them. Check the explanation! 🛡️",
    'l23': "Not quite! Compound interest math is subtle. The explanation makes it crystal clear. ✨",
    'l24': "Almost! Inflation concepts are tricky. Read the explanation — it's one of the most important ideas in finance. 📉",
    'l25': "Not this time! Banking basics have some surprising details. Read the explanation! 🏦",
    'l26': "Student loan rules are complex by design. Read the explanation — this knowledge is worth thousands. 🎓",
  };

  // ── Lesson completion messages ────────────────────────────────────────────────

  static const Map<String, String> _completionMessages = {
    'l1': "You now know what a stock is — that puts you ahead of most people your age! Every great investor started right here. 🌱",
    'l2': "You understand how markets work now! The NYSE floor used to be all shouting traders. Now it's mostly computers. Wild, right? 📈",
    'l3': "Chart reading is a real skill and you've got it! Those candlesticks will never look like gibberish again. 📊",
    'l4': "Bid/ask spreads are invisible costs most people never think about. You're already thinking smarter! 💱",
    'l5': "Diversification is literally one of the most valuable concepts in all of investing. You've got it! 🥧",
    'l6': "Understanding risk vs return is the foundation of every investment decision. You're thinking like a pro! ⚖️",
    'l7': "Asset allocation is what separates structured investors from gamblers. You've got the framework now! 🗂️",
    'l8': "ETF knowledge is incredibly powerful. Index investing has created more wealth than almost any other strategy. 🧺",
    'l9': "Real estate investing isn't just for the rich anymore! You've got the tools to explore it. 🏠",
    'l10': "REITs are one of the most underrated investments out there. Now you know why the pros love them! 🏢",
    'l11': "DCA is honestly one of the best habits you can build. Set it, forget it, watch it grow! 📅",
    'l12': "Value vs growth — two great strategies, endlessly debated on Wall Street. You understand both now! 🔍",
    'l13': "Dividend investing is how many people build passive income streams. You've got the foundation! 💰",
    'l14': "Technical analysis adds another layer to your investing toolkit. The charts will start talking to you! 📉",
    'l15': "Options are genuinely complex — the fact that you got through this is impressive. Handle them carefully! 🎯",
    'l16': "You understand short selling now. Most people don't. Use this knowledge wisely! 📉",
    'l17': "Margin trading is powerful and dangerous in equal measure. You're prepared to use it responsibly. ⚡",
    'l18': "Crypto fundamentals — check! You understand the tech AND the risks. That's rare. 🪙",
    'l19': "You now have a budgeting framework that most adults never learn. The 50/30/20 rule will serve you for life! 💵",
    'l20': "Credit score knowledge is worth real money — better rates on cars, apartments, mortgages. You are ahead of the game! 💳",
    'l21': "Taxes demystified! Most people just hand over money without understanding where it goes. You are not most people. 🧾",
    'l22': "Emergency fund locked in! This is the unsexy but most important first step in any financial plan. Build it first. 🛡️",
    'l23': "Compound interest is now your superpower. Start investing as early as possible and let time do the heavy lifting. ✨",
    'l24': "You understand inflation — which means you understand why investing is not optional for long-term wealth. Well done! 📉",
    'l25': "Banking basics complete! Switch to a HYSA if you have not already — it is the easiest free money available. 🏦",
    'l26': "Student loan wisdom earned! Borrowing smart at the start of your education can save decades of financial stress. 🎓",
  };

  // ── Onboarding dialogue ───────────────────────────────────────────────────────

  static const String onboardingWelcome =
      "Hey! I'm Cash — your personal investing sidekick! I'll explain tricky concepts, cheer you on during quizzes, and help your money tree grow. Let's do this! 🌱";

  static const Map<String, String> ageGroupComments = {
    'High School':
        "Starting young is your absolute biggest advantage — time is literally on your side. Warren Buffett started at 11! ⏰",
    'College':
        "Smart move! Many future millionaires started investing in college. You're already ahead of the curve! 📚",
    'Young Professional':
        "The best time to invest was yesterday. The second best time? Right now. Let's get those seeds planted! 💼",
    'Adult':
        "It's NEVER too late to grow your money tree. Compound interest works at any age. Let's build something great! 🌳",
  };

  /// Cash reacts to each answer in the onboarding risk quiz.
  /// Indexed by [questionIndex][optionIndex (0=cautious, 1=balanced, 2=bold)].
  static const List<List<String>> quizChoiceComments = [
    // Q1: Market drops 20%
    [
      "Playing it safe! Protecting capital is valid — though historically, those who held through drops came out ahead. 🛡️",
      "Smart move! Patience during dips is usually rewarded. You've got a steady head on your shoulders!",
      "Bold! Buying the dip takes nerves of steel — Warren Buffett literally loves doing this. 🦁",
    ],
    // Q2: Investing style
    [
      "Slow and steady absolutely wins races! Consistent low-risk returns beat risky gambles over time.",
      "Balanced is wise — most financial advisors recommend a healthy mix of risk anyway! ⚖️",
      "Maximum growth potential! Just be ready for some wild market rollercoasters along the way. 🎢",
    ],
    // Q3: Time horizon
    [
      "Short horizon means keeping things safer — your capital preservation instinct is spot on! 🛡️",
      "A few years is a solid window. Enough time for markets to recover from dips and reward patience!",
      "The LONG game! Compound interest will be your best friend. Einstein called it the 8th wonder of the world! 🌟",
    ],
  ];

  static const Map<String, String> profileReactions = {
    'Careful Planter':
        "A Careful Planter — wise and steady! ETFs, dividend stocks, and bonds will help your garden grow safely over time. 🌱",
    'Balanced Builder':
        "A Balanced Builder — you've got the best of both worlds! Mix growth and stability and you'll be unstoppable. ⚖️",
    'Bold Investor':
        "A Bold Investor — let's GO! You're ready for the market's waves. Just remember: research before every big bet! 🚀",
  };

  // ── Dashboard daily tips ──────────────────────────────────────────────────────
  // 14 tips — cycles by day of month (mod 14)

  static const List<String> _dailyTips = [
    "The best time to plant a tree was 20 years ago. Second best time: right now. Same logic applies to investing! 🌳",
    "Index funds outperform 92% of active fund managers over 20 years. Sometimes boring IS the smartest play.",
    "Compound interest: earning returns on your returns. Einstein called it the 8th wonder of the world! ✨",
    "Diversify! A portfolio spread across stocks, bonds, and sectors weathers market storms far better.",
    "Build your emergency fund (3–6 months of expenses) BEFORE investing. Safety first, then growth! 🛡️",
    "Fees eat your returns silently. A 1% annual fee on \$10,000 over 30 years costs you ~\$14,000 in lost gains.",
    "Investing \$100/month from age 22 → ~\$350,000 by 65 at 7% avg return. Start small, start now! 💪",
    "Fear and greed drive markets. Try to be greedy when others are fearful, and fearful when others are greedy!",
    "A stock's price is what you pay; its value is what you actually get. Learning to tell them apart is a superpower. 🔍",
    "Dividend reinvestment (DRIP) quietly snowballs your wealth. Small flakes today, avalanche tomorrow! ☃️",
    "Tax-advantaged accounts (401k, Roth IRA) should usually be maxed before a regular brokerage account. That's free money!",
    "Dollar-cost averaging removes the impossible task of timing the market. Invest consistently and let time do its thing!",
    "P/E ratio = how many years of current earnings you're paying for. A P/E of 20 means paying 20× annual earnings.",
    "The market has recovered from every single crash in history. Temporary pain, long-term gain! 📈",
  ];

  // ── Public accessors ──────────────────────────────────────────────────────────

  /// Returns the Cash tip for a given lesson slide, or null if none exists.
  static String? getSlideTip(String lessonId, int slideIndex) {
    final tips = _slideTips[lessonId];
    if (tips == null || slideIndex >= tips.length) return null;
    return tips[slideIndex];
  }

  /// Returns the quiz hint for a specific question in a lesson.
  static String getQuizHint(String lessonId, int questionIndex) {
    final hints = _quizHints[lessonId];
    if (hints == null || questionIndex >= hints.length) {
      return "Take your time — what makes the most sense to you? 🤔";
    }
    return hints[questionIndex];
  }

  /// Returns the correct-answer reaction for a lesson.
  static String getCorrectMessage(String lessonId) =>
      _correctMessages[lessonId] ?? "Nailed it! You're a natural investor! 🎉";

  /// Returns the wrong-answer encouragement for a lesson.
  static String getWrongMessage(String lessonId) =>
      _wrongMessages[lessonId] ??
      "No worries! Even Warren Buffett made mistakes starting out. Read the explanation — it'll click! 🌱";

  /// Returns Cash's completion message for a lesson.
  static String getCompletionMessage(String lessonId) =>
      _completionMessages[lessonId] ??
      "Lesson complete! Keep building those investing skills! 🌱";

  /// Returns a daily tip that rotates by day of month.
  static String getDailyTip() {
    final index = DateTime.now().day % _dailyTips.length;
    return _dailyTips[index];
  }
}
