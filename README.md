# Stata Microeconomics Project – NBA Analysis

## Overview
This project studies how rookie-scale contract extensions affect NBA players’ contribution to team success (Win Shares) in seasons 4-6. 
It focuses on the top 14 draft picks from 2007-2015, using econometric techniques to identify causal effects.

## Theoretical Motivation
The analysis is framed within a principal-agent model. While players typically adjust effort throughout the contract cycle, 
this project examines whether rookie-scale extensions shift incentives for younger players, aligning individual and team goals temporarily.

## Data
- Player-season observations (N = 123 in season 4, 115 in season 5, 105 in season 6)  
- Sources: NBA statistics websites (details in Table 1 of the report)  
- Key variables: Win Shares (WS), extension indicator, draft position, control variables (pre-treatment performance metrics)

## Methodology
- Two-stage least squares (2SLS) to address endogeneity  
- Instrument: reciprocal of draft position  
- Outcomes: Win Shares in seasons 4-6  
- Controls: performance trends, managerial decisions, draft year fixed effects, team fixed effects

## Key Findings
- Extensions have a significant positive effect on season 4 Win Shares (+5.07)  
- No significant effect in seasons 5-6  
- Suggests rookie extensions temporarily resolve the goal conflict between personal showcasing and team contribution
